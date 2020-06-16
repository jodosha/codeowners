# frozen_string_literal: true

require "codeowners"
require "dry/cli"

module Codeowners
  module CLI
    module Commands
      extend Dry::CLI::Registry

      class Command < Dry::CLI::Command
        def initialize(out: $stdout)
          @out = out
        end

        private

        attr_reader :out
      end

      class Version < Command
        desc "Print version"

        def call(*)
          out.puts "v#{Codeowners::VERSION}"
        end
      end

      class List < Command
        DEFAULT_BASE_DIRECTORY = Dir.pwd.dup.freeze
        private_constant :DEFAULT_BASE_DIRECTORY

        DEFAULT_CODEOWNERS_PATH = ::File.join(".github", "CODEOWNERS").freeze
        private_constant :DEFAULT_CODEOWNERS_PATH

        desc "List code owners for a file, if any"

        argument :file, required: true, desc: "File to check"

        option :base_directory, type: :string, default: DEFAULT_BASE_DIRECTORY,  desc: "Base directory"
        option :codeowners,     type: :string, default: DEFAULT_CODEOWNERS_PATH, desc: "Path to CODEOWNERS file"

        def call(file:, base_directory:, codeowners:, **)
          result = Codeowners::ListOwners.new(base_directory, codeowners).call(file)
          exit(1) unless result.successful?

          out.puts result.to_s
        end
      end

      class Contributors < Command
        DEFAULT_BASE_DIRECTORY = Dir.pwd.dup.freeze
        private_constant :DEFAULT_BASE_DIRECTORY

        DEFAULT_CODEOWNERS_PATH = ::File.join(".github", "CODEOWNERS").freeze
        private_constant :DEFAULT_CODEOWNERS_PATH

        desc "List code contributors for a file (or a pattern)"

        argument :file, required: true, desc: "File (or pattern) to check"

        option :base_directory, type: :string, default: DEFAULT_BASE_DIRECTORY, desc: "Base directory"

        example [
          "path/to/file.rb # file",
          "'path/to/**/*.rb' # pattern"
        ]

        def call(file:, base_directory:, **)
          result = Codeowners::ListContributors.new(base_directory).call(file)
          exit(1) unless result.successful?

          out.puts result.to_s
        end
      end

      register "version",      Version, aliases: ["v", "-v", "--version"]
      register "list",         List
      register "contributors", Contributors
    end
  end
end
