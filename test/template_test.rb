require 'test_helper'

class PluginsTest < MiniTest::Unit::TestCase
  describe "#template" do
    let (:template) do 
      Rubarb::Template.new do
        "#{foo} - #{bar}"
      end
    end 

    it "alters a string, using a hash as reference" do
      template.render({foo: "FOO", bar: "BAR"}).must_equal "FOO - BAR"
    end 
  end 
end 
