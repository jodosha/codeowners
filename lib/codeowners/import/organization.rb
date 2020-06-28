# frozen_string_literal: true

module Codeowners
  module Import
    class Organization
      def initialize(client, storage)
        @client = client
        @storage = storage
      end

      def call(org, debug)
        org = client.org(org, debug)
        users = client.org_members(org, debug)
        users = client.users(users, debug)
        teams = client.teams(org, debug)
        memberships = client.team_members(org, teams, debug)

        storage.transaction do |db|
          db[:orgs].upsert(org)
          db[:users].upsert(users)
          db[:teams].upsert(teams)
          db[:memberships].upsert(memberships)
        end
      end

      private

      attr_reader :client
      attr_reader :storage
    end
  end
end
