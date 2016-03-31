$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "/../lib"))
require 'sprite'
require 'bundler/setup'

require 'date'
require 'fileutils'

# set Sprite.root to be this spec/ folder
Sprite.module_eval{ @root = File.dirname(__FILE__) }

FileUtils.rm_rf("#{Sprite.root}/output")

RSpec.configure do |c|

  module SpriteSpecHelpers
    def clear_output
      FileUtils.rm_rf("#{Sprite.root}/output")
    end
  end

  c.include(SpriteSpecHelpers)

  # setup fixtures path
  c.before(:all) do
  end

  c.mock_with :rspec

  # returns the file path of a fixture setting file
  def config_path(filename)
    @fixture_path.join(filename)
  end

end
