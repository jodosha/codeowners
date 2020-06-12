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
        lines.each_slice(3) do |slice|
          author_name, author_email, insertions, deletions = parse(slice)

          result[author_email] ||= {}
          result[author_email]["name"] = author_name
          result[author_email]["file"] = file
          result[author_email]["insertions"] ||= 0
          result[author_email]["deletions"] ||= 0
          result[author_email]["insertions"] += insertions
          result[author_email]["deletions"] += deletions
        end

        new(result)
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def self.parse(slice)
        author, stats, = *slice
        author_name = author.split(" <").first
        author_email = Array(author.scan(/<(.*)>/)).flatten.first
        stats = stats.split(", ")

        _, insertions, deletions = *stats
        insertions = insertions.to_i
        deletions = deletions.to_i

        [author_name, author_email, insertions, deletions]
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
