# frozen_string_literal: true

module Codeowners
  require "codeowners/version"
  require "codeowners/result"
  require "codeowners/storage"
  require "codeowners/list_owners"
  require "codeowners/list_contributors"
  require "codeowners/guess"
  require "codeowners/import/client"
  require "codeowners/import/organization"

  class Error < StandardError
  end

  class SystemCallError < Error
  end
end
