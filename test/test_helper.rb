#require 'test/unit'
require 'pry'
require 'minitest/autorun'

$LOAD_PATH << "#{File.dirname(__FILE__)}/../lib"
require 'rubarb'
Rubarb::PluginDispatcher.all_plugins

