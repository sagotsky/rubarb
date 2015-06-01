class RubarbPlugin
  def run
    raise "Implement run in your RubarbPlugin class"
  end

  # turns output into string for display.  does it make sense for a plugin to override the cal to the lambda?
  def format(output)
    output = output.to_s.strip
    output = @format.call(output) if @format
    output
  end

  def respawn
    @respawn || 60
  end

  def self.option(name)
    define_method(name) do |value|
      instance_variable_set("@#{name}", value)    
    end
  end
end

class Reader < RubarbPlugin
end

class StdinReader < RubarbPlugin
end

#class Wm < RubarbPlugin
  # maybe this would be a better place than ewmhstatus to subscribe to wm notifications?
# end 

# this plugin is stupid, but a decent example if you want to watch the cache update on schedule
class Counter < RubarbPlugin
  #option :color

  def initialize
    @c = 0
  end
  
  def run
    @c += 1
  end
end

class Script < RubarbPlugin
  def run
    process.gets || begin
      @process = nil
      process.gets
    end
  end

  def respawn
    still_running? ? 0 : super
  end

  private

  def still_running?
    # if the last getrs is nil?  is there better?
    binding.pry 
    false
  end

  def process
    @process ||= IO.popen(@exec) # how about if it crashes?  
  end 
end 

class Clock < RubarbPlugin
  def run
    Time.now
  end
end
