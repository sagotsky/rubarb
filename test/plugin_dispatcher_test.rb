require 'test_helper'

class PluginDispatcherTest < MiniTest::Unit::TestCase
  describe '#plugin_dispatcher' do
    let (:rubarb) do
      {} # stub/mock?
    end

    let (:plugin_dispatcher) do
      Rubarb::PluginDispatcher.new rubarb, :counter do
        @respawn = 0 
      end 
    end

    it "instantiates a plugin" do
      plugin = plugin_dispatcher.instance_variable_get('@plugin')
      plugin.class.must_equal Rubarb::Counter
    end

    it "reads output from a plugin" do
      plugin_dispatcher.send :run_plugin
      plugin_dispatcher.refresh
      plugin_dispatcher.output.wont_equal ''
    end

    it "caches plugin_output" do
      plugin_dispatcher.send :run_plugin
      plugin_dispatcher.refresh
      out = plugin_dispatcher.output

      5.times {plugin_dispatcher.send :run_plugin}
      out.must_equal plugin_dispatcher.output

      plugin_dispatcher.refresh
      out.wont_equal plugin_dispatcher.output
    end

  end 

  describe '#plugin_dispatcher class methods' do
    let (:clock) { Rubarb::PluginDispatcher.plugin(:clock)}

    it "accesses a plugin by name" do
      clock.must_equal Rubarb::Clock  
    end
  end
end 
