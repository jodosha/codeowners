# frozen_string_literal: true

require "pathname"

module Codeowners
  class ListOwners
    def initialize(base_directory, codeowners)
      @base_directory = Pathname.new(::File.expand_path(base_directory))
      @codeowners = @base_directory.join(codeowners)
    end

    def call(file)
      ::File.open(@codeowners, "r").each_line do |line|
        line = line.chomp
        next if line.empty? || line.match?(/[[:space:]]*#/)

        pattern, *owners = line.split(/[[:space:]]+/)

        return Result.new(pattern, owners) if File.fnmatch(pattern, file)
      end

      Result.new
    end
  end
end
