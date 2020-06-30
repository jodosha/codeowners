# frozen_string_literal: true

require "json"
require "tempfile"
require "fileutils"

module Codeowners
  class Storage
    require "codeowners/storage/data"

    def initialize(path)
      @path = path
      @data = Data.new(load_data)
      @mutex = Mutex.new
    end

    def transaction
      @mutex.synchronize do
        tmp_data = data.dup
        yield tmp_data

        Tempfile.open("codeowners-storage") do |tmp|
          tmp.binmode
          tmp.write(JSON.generate(data.dump))
          tmp.close

          FileUtils.mv(tmp.path, path, force: true)
        end
      end
    end

    def team_exist?(team)
      data[:teams].find do |record|
        record.fetch("slug") == team
      end
    end

    def blacklisted_team?(team)
      data[:teams].find do |record|
        record.fetch("slug") == team &&
          record.fetch("blacklisted")
      end
    end

    def teams_for(user)
      found = data[:users].find do |record|
        record.fetch("email") == user.email ||
          record.fetch("name") == user.name
      end

      return [] unless found

      memberships = data[:memberships].find_all do |record|
        record.fetch("user_id") == found.fetch("id")
      end
      memberships.map! { |hash| hash.fetch("team_id") }

      return [] if memberships.empty?

      teams = data[:teams].find_all do |record|
        !record.fetch("blacklisted") &&
          memberships.include?(record.fetch("id"))
      end.flatten

      teams
    end

    private

    attr_reader :path
    attr_reader :data

    def load_data
      return {} unless File.exist?(path)

      JSON.parse(File.read(path))
    end
  end
end
