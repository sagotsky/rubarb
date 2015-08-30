require 'test_helper'

class ConfigReaderTest < MiniTest::Unit::TestCase
  describe "#config_reader" do
    let (:reader) do
      Rubarb::ConfigReader.new %w[foo bar baz] 
    end 

    let (:cfg_string) do
      <<-EOF
        foo 'a'
        bar 'b'
        baz 'c'
      EOF
    end

    let (:cfg_block) do
      -> (*args) {
        foo 1
        bar 2
        baz 3
      }
    end

    it "evals a config string" do 
      expects = {foo: ?a, bar: ?b, baz: ?c}.map {|k,v| [k, [v]]}
      reader.parse(cfg_string).must_equal expects
    end

    it "evals a config block" do 
      expects = {foo: 1, bar: 2, baz: 3}.map {|k,v| [k, [v]]}
      reader.parse(cfg_block).must_equal expects
    end

    it "can store a proc in config" do 
      reader.parse -> (*args) {
        foo do 
          "bar" 
        end
      }
        
      reader.find(:foo).call().must_equal "bar"
    end

    it "finds a value by key" do 
      reader.parse(cfg_block)
      reader.find(:baz).must_equal 3
    end

    it "slices values by key" do 
      reader.parse(cfg_block)
      reader.slice([:foo, :bar]).must_equal({foo: [1], bar: [2]}.to_a)
    end

    it "slices values by key and returns a hash of the first value per key" do 
      reader.parse(cfg_block)
      reader.hash_slice([:foo, :bar]).must_equal({foo: 1, bar: 2})
    end
  end 
end 
