require 'test_helper'

class PluginsTest < MiniTest::Unit::TestCase
  describe "#plugin output" do
    let (:clock) { Rubarb::Clock.new({}) }

    let (:script) do
      Rubarb::Script.new sh: 'uname -r'
    end

    let (:counter) { Rubarb::Counter.new({}) }

    let (:memory) { Rubarb::Memory.new({}) }

    let (:cpu) { Rubarb::Cpu.new({}) }

    it "clock" do
      Time.now.to_s.must_equal clock.run.to_s
    end 

    it "script" do
      script.run.must_equal `uname -r`
    end

    it "counter" do
      Array.new(4).map{ counter.run }.must_equal [1,2,3,4]
    end

    it "memory" do
      usage = memory.run
      usage.must_be :>=, 0
      usage.must_be :<=, 100
    end

    it "cpu" do
      usage = cpu.run
      usage.must_be :>=, 0
      usage.must_be :<=, 100
    end
  end
end
