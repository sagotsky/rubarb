require 'test_helper'

class RubarbTest < MiniTest::Unit::TestCase
  describe "rubarb" do
    let (:rubarb) do
      Rubarb.new config: <<-'EOF'
        clock {
          respawn 5
          token :date
        }

        template do 
          "#{date}"
        end
      EOF
    end 

    it "'s alive!" do
      rubarb
      puts 'ran'
    end
  end 
end 
