# frozen_string_literal: true

require "English"
require "codeowners/git/contributor"

module Codeowners
  class Git
    class Contributors
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def self.call(file, output)
        lines = output.split($INPUT_RECORD_SEPARATOR)

        result = {}
        each_commit(lines) do |authors, insertions, deletions|
          authors.each do |author|
            author_email = author.fetch("email")
            author_name  = author.fetch("name")

            result[author_email] ||= {}
            result[author_email]["name"] = author_name
            result[author_email]["file"] = file
            result[author_email]["insertions"] ||= 0
            result[author_email]["deletions"] ||= 0
            result[author_email]["insertions"] += insertions
            result[author_email]["deletions"] += deletions
          end
        end

        new(result)
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def self.each_commit(lines)
        while lines.any?
          commit = lines.take_while { |line| line != "" }
          yield parse(commit.dup) unless commit.empty?
          lines.shift(commit.size + 1)
        end
      end

      def self.parse(commit)
        authors, stats = commit.partition { |line| line.match?(/author:/) }

        [extract_authors(authors), *calculate_stats(stats)]
      end

      def self.extract_authors(authors)
        authors.map do |author|
          {
            "name" => scan(author, /author:(.*)email:/).chop,
            "email" => scan(author, /email:(.*)/)
          }
        end.uniq
      end

      def self.calculate_stats(stats)
        stats.each_with_object([0, 0]) do |stat, result|
          stat = stat.split(/[[:space:]]+/)

          insertions, deletions, = *stat
          result[0] += Integer(insertions)
          result[1] += Integer(deletions)
        end
      end

      def self.scan(string, pattern)
        string.scan(pattern).flatten.first
      end

      def initialize(data)
        @contributors = data.map do |email, stats|
          Contributor.new(email, *stats.values)
        end
      end

      def each(&blk)
        return enum_for(:each) unless block_given?

        @contributors.each(&blk)
      end

      def empty?
        @contributors.empty?
      end
    end
  end
end
