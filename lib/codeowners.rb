# frozen_string_literal: true

module Codeowners
  require "codeowners/version"
  require "codeowners/result"
  require "codeowners/list_owners"
  require "codeowners/list_contributors"

  class Error < StandardError
  end

  class SystemCallError < Error
  end
end
