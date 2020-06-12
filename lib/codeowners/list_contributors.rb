# frozen_string_literal: true

require "codeowners/git"

module Codeowners
  class ListContributors
    class Result < ::Codeowners::Result
      def initialize(file = nil, contributors = [])
        @file = file
        @contributors = contributors
      end

      def successful?
        !@file.nil?
      end

      def to_s
        [@file, "", *@contributors.map(&:to_s)].join("\n")
      end
    end

    def initialize(base_directory, git: Git.new(base_directory))
      @git = git
    end

    def call(file)
      contributors = @git.contributors(file)
      return Result.new if contributors.empty?

      contributors = contributors.each.lazy.sort_by { |c| -c.insertions }

      Result.new(file, contributors)
    end
  end
end
