module Rubarb
  class Rubarb::Clock < Rubarb::RubarbPlugin
    def run
      Time.now
    end
  end
end
