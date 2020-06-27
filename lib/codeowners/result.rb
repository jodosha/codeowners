# frozen_string_literal: true

module Codeowners
  class Result
    attr_reader :owners

    def initialize(pattern = nil, owners = [])
      @pattern = pattern
      @owners = owners
    end

    def successful?
      !@pattern.nil?
    end

    def to_s
      "#{@pattern}\n\n#{@owners.join('\n')}"
    end
  end
end
