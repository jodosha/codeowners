# frozen_string_literal: true

require "json"
require "tempfile"
require "fileutils"

module Codeowners
  class Storage
    require "codeowners/storage/data"

    def initialize(path)
      @path = path
      @data = Data.new(load_data)
      @mutex = Mutex.new
    end

    def transaction
      @mutex.synchronize do
        tmp_data = data.dup
        yield tmp_data

        Tempfile.open("codeowners-storage") do |tmp|
          tmp.binmode
          tmp.write(JSON.generate(data.dump))
          tmp.close

          FileUtils.mv(tmp.path, path, force: true)
        end
      end
    end

    private

    attr_reader :path
    attr_reader :data

    def load_data
      return {} unless File.exist?(path)

      JSON.parse(File.read(path))
    end
  end
end
