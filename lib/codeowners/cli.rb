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

        FORMAT_MAPPING = { "string" => "to_s", "csv" => "to_csv" }.freeze
        private_constant :FORMAT_MAPPING

        FORMAT_VALUES = FORMAT_MAPPING.keys.freeze
        private_constant :FORMAT_VALUES

        DEFAULT_FORMAT = FORMAT_VALUES.first
        private_constant :DEFAULT_FORMAT

        DEFAULT_DEBUG = false
        private_constant :DEFAULT_DEBUG

        desc "List code contributors for a file (or a pattern)"

        argument :file, required: true, desc: "File (or pattern) to check"

        option :base_directory, type: :string, default: DEFAULT_BASE_DIRECTORY, desc: "Base directory"
        option :format, type: :string, default: DEFAULT_FORMAT, values: FORMAT_VALUES, desc: "Output format"
        option :debug, type: :boolean, default: DEFAULT_DEBUG, desc: "Print debug information to stdout"

        example [
          "path/to/file.rb # file",
          "'path/to/**/*.rb' # pattern"
        ]

        def call(file:, base_directory:, format:, debug:, **)
          result = Codeowners::ListContributors.new(base_directory).call(file, debug)
          exit(1) unless result.successful?

          out.puts output(result, format)
        end

        private

        def output(result, format)
          method_name = FORMAT_MAPPING.fetch(format)
          result.public_send(method_name.to_sym)
        end
      end

      module Import
        class Org < Command
          DEFAULT_STORAGE_PATH = ::File.join(Dir.pwd, "codeowners.json").freeze
          private_constant :DEFAULT_STORAGE_PATH

          DEFAULT_DEBUG = false
          private_constant :DEFAULT_DEBUG

          desc "Import teams and members for a GitHub organization"

          argument :org, required: true, desc: "GitHub organization login"
          argument :token, required: true, desc: "GitHub APIv3 token"

          option :storage, type: :string, default: DEFAULT_STORAGE_PATH, desc: "Storage path (default: #{DEFAULT_STORAGE_PATH})"
          option :debug, type: :boolean, default: DEFAULT_DEBUG, desc: "Print debug information to stdout"

          example [
            "hanami s3cr374p1t0k3n"
          ]

          def call(org:, token:, storage:, debug:, **)
            client = Codeowners::Import::Client.new(token, out)
            storage = Codeowners::Storage.new(storage)

            Codeowners::Import::Organization.new(client, storage).call(org, debug)
          end
        end
      end

      register "version",      Version, aliases: ["v", "-v", "--version"]
      register "list",         List
      register "contributors", Contributors

      register "import" do |prefix|
        prefix.register "org", Import::Org
      end
    end
  end
end
