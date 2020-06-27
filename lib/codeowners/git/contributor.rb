# frozen_string_literal: true

module Codeowners
  class Git
    class Contributor
      attr_reader :email, :name, :file, :insertions, :deletions

      def initialize(email, name, file, insertions, deletions)
        @email = email
        @name = name
        @file = file
        @insertions = insertions
        @deletions = deletions

        freeze
      end

      def to_s
        "#{name} <#{email}> / +#{insertions}, -#{deletions}"
      end

      def to_csv
        "#{name}, #{email}, #{insertions}, #{deletions}"
      end
    end
  end
end
