# frozen_string_literal: true

require "pathname"
require "shellwords"

module Codeowners
  class Git
    def initialize(base_directory)
      @base_directory = Pathname.new(::File.expand_path(base_directory))
    end

    def contributors(file, debug = false)
      require "codeowners/git/contributors"
      output = git(["log", "--numstat", %(--pretty=format:"author:%aN email:%ae"), "--no-color", "--", escape(file)])
      print_debug(output, debug)

      Contributors.call(file, output)
    end

    private

    def git(command_and_args)
      execute(["git", "--git-dir=#{git_directory}", "--work-tree=#{work_tree}", "-c", "'color.ui=false'"] + command_and_args)
    end

    def work_tree
      escape(@base_directory.to_s)
    end

    def git_directory
      escape(@base_directory.join(".git").to_s)
    end

    def escape(string)
      Shellwords.shellescape(string)
    end

    def execute(command, env: {}, error: ->(err) { raise Codeowners::SystemCallError.new(err) })
      require "open3"

      Open3.popen3(env, command.join(" ")) do |_, stdout, stderr, wait_thr|
        error.call(stderr.read) unless wait_thr.value.success?
        return stdout.read
      end
    end

    def print_debug(output, debug)
      return unless debug

      puts output
      puts "\n" * 10
    end
  end
end
