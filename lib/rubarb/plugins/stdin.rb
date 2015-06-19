module Rubarb
  class Stdin < RubarbPlugin
    def run
      STDIN.gets
    end

    def respawn
      STDIN.eof? ? super : 0
    end

  end
end 
