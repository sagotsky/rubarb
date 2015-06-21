require 'test_helper'

class PluginsTest < MiniTest::Unit::TestCase
  describe "#plugins" do
    let (:clock) { Rubarb::Clock.new({}) }

    let (:script) do
      Rubarb::Script.new sh: 'uname -r'
    end

    let (:counter) { Rubarb::Counter.new({}) }

    it "clock" do
      Time.now.to_s.must_equal clock.run.to_s
    end 

    it "script" do
      script.run.must_equal `uname -r`
    end

    it "counter" do
      Array.new(4).map{ counter.run }.must_equal [1,2,3,4]
    end
  end
end
