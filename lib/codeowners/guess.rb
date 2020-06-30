# frozen_string_literal: true

module Codeowners
  class Guess
    def initialize(owners, contributors, storage, base_directory, out)
      @owners = owners
      @contributors = contributors
      @storage = storage
      @base_directory = ::File.expand_path(base_directory)
      @out = out
    end

    def call(file, debug)
      result = {}

      Dir.chdir(base_directory) do
        Dir.glob(file).sort.each do |f|
          *teams, codeowners = list_code_owners(f, debug)
          *teams, codeowners = guess_code_owners(f, debug) unless codeowners
          teams ||= []

          result[f] = { teams: teams, codeowners: codeowners }
        end
      end

      result
    end

    private

    attr_reader :owners
    attr_reader :contributors
    attr_reader :storage
    attr_reader :base_directory
    attr_reader :out

    def list_code_owners(file, _debug)
      result = owners.call(file)

      if result.successful?
        teams = result.to_a.find_all do |team|
          storage.team_exist?(team) &&
            !storage.blacklisted_team?(team)
        end

        return [result, true] if teams.any?
      end

      [nil, false]
    end

    def guess_code_owners(file, debug)
      result = contributors.call(file, debug)
      return [nil, false] unless result.successful?

      contributors = result.to_a
      result = contributors.each_with_object({}) do |contributor, memo|
        teams = storage.teams_for(contributor)
        teams.each do |team|
          slug = team.fetch("slug")

          memo[slug] ||= {}
          memo[slug][:insertions] ||= 0
          memo[slug][:deletions] ||= 0
          memo[slug][:insertions] += contributor.insertions
          memo[slug][:deletions] += contributor.deletions
        end
      end

      team = result.sort do |a, b|
        -a.last.fetch(:insertions) <=> -b.last.fetch(:insertions)
      end&.first&.first

      [team, false]
    end
  end
end
