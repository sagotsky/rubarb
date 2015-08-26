require 'test_helper'

class RubarbTest < MiniTest::Unit::TestCase
  describe "rubarb" do
    let (:rubarb) do
      Rubarb.new # this can't read from rubarbrc..
    end 

    it "'s alive!" do
      rubarb.run
    end
  end 
end 
