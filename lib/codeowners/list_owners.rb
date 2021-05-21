# frozen_string_literal: true

require "pathname"

module Codeowners
  class ListOwners
    def initialize(base_directory, codeowners)
      @base_directory = Pathname.new(::File.expand_path(base_directory))
      @codeowners = @base_directory.join(codeowners)
    end

    def call(file)
      result = Result.new

      ::File.open(@codeowners, "r").each_line do |line|
        line = line.chomp
        next if line.empty? || line.match?(/[[:space:]]*#/)

        pattern, *owners = line.split(/[[:space:]]+/)

        result = Result.new(pattern, owners) if match?(pattern, file)
      end

      result
    end

    private

    def match?(pattern, file)
      pattern = normalize_pattern(pattern)
      flags = match_flags_for(pattern)

      File.fnmatch(pattern, file, flags)
    end

    def normalize_pattern(pattern)
      pattern += "**" if pattern.end_with?(::File::SEPARATOR)
      pattern
    end

    def match_flags_for(pattern)
      return File::FNM_PATHNAME if pattern.end_with?(::File::SEPARATOR + "*")

      0
    end
  end
end
