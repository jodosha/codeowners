# frozen_string_literal: true

require "json"
require "excon"

module Codeowners
  module Import
    class Client
      BASE_URL = "https://api.github.com"
      private_constant :BASE_URL

      USER_AGENT = "codeowners v#{Codeowners::VERSION}"
      private_constant :USER_AGENT

      def initialize(token, out, base_url = BASE_URL, user_agent = USER_AGENT, client = Excon, sleep_time: 3)
        @base_url = base_url
        @user_agent = user_agent
        @token = token
        @client = client
        @out = out
        @sleep_time = sleep_time
      end

      def org(login, debug = false)
        result = get("/orgs/#{login}", debug: debug)

        {
          id: result.fetch("id"),
          login: result.fetch("login")
        }
      end

      def org_members(org, debug = false)
        result = get_paginated("/orgs/#{org.fetch(:login)}/members", debug: debug)
        result.map do |user|
          {
            id: user.fetch("id"),
            login: user.fetch("login")
          }
        end
      end

      def teams(org, debug = false)
        result = get_paginated("/orgs/#{org.fetch(:login)}/teams", debug: debug)
        result.map do |team|
          {
            id: team.fetch("id"),
            org_id: org.fetch(:id),
            name: team.fetch("name"),
            slug: team.fetch("slug")
          }
        end
      end

      def team_members(org, teams, debug = false)
        teams.each_with_object([]) do |team, memo|
          result = get_paginated("/orgs/#{org.fetch(:login)}/teams/#{team.fetch(:slug)}/members", debug: debug)
          result.each do |member|
            team_id = team.fetch(:id)
            user_id = member.fetch("id")

            memo << {
              id: [team_id, user_id],
              team_id: team_id,
              user_id: user_id
            }
          end

          sleep_for_a_while
        end
      end

      def users(users, debug)
        users.each do |user|
          remote_user = get("/users/#{user.fetch(:login)}", debug: debug)
          user.merge!(
            name: remote_user.fetch("name"),
            email: remote_user.fetch("email")
          )

          sleep_for_a_while
        end
      end

      private

      attr_reader :base_url
      attr_reader :user_agent
      attr_reader :token
      attr_reader :client
      attr_reader :out
      attr_reader :sleep_time

      def get(path, debug: false)
        out.puts "requesting GET #{path}" if debug

        response = client.get(base_url + path, query: query, headers: headers)
        return {} unless response.status == 200

        JSON.parse(response.body)
      end

      def get_paginated(path, result = [], debug: false, page: 1)
        out.puts "requesting GET #{path}, page: #{page}" if debug

        response = client.get(base_url + path, query: query(page: page), headers: headers)
        return [] unless response.status == 200

        parsed = JSON.parse(response.body)
        result.push(parsed)

        if parsed.any?
          sleep_for_a_while
          get_paginated(path, result, debug: debug, page: page + 1)
        else
          result.flatten
        end
      end

      def query(options = {})
        { page: 1, per_page: 100 }.merge(options)
      end

      def headers
        {
          "Authorization" => "token #{token}",
          "User-Agent" => user_agent
        }
      end

      def sleep_for_a_while
        sleep(sleep_time)
      end
    end
  end
end
