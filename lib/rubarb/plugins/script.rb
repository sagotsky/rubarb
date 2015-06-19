module Rubarb
  class Script < RubarbPlugin
    add_option :sh

    def run
      process.gets # still might need to catch something here.   TODO try busted scripts
    end

    def respawn
      @process.eof? ? super : 0
    end

    private

    def process
      @process = @process.close if @process && @process.eof?
      @process ||= IO.popen(@sh) 
    end 
  end
end 
