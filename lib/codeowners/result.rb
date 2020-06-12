# frozen_string_literal: true

module Codeowners
  class Result
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
