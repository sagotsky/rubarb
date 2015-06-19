module Rubarb
  class Clock < RubarbPlugin
    def run
      Time.now
    end
  end
end
