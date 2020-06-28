# frozen_string_literal: true

require "codeowners/storage/collection"

module Codeowners
  class Storage
    class Data
      COLLECTIONS = %w[orgs users teams memberships].freeze
      private_constant :COLLECTIONS

      def initialize(data, collections: COLLECTIONS)
        @data = collections.each_with_object({}) do |name, memo|
          memo[name] = Collection.new(data.fetch(name, []))
        end
      end

      def [](name)
        data.fetch(name.to_s)
      end

      def dump
        data.transform_values(&:dump)
      end

      private

      attr_reader :data
    end
  end
end
