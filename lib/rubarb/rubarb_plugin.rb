class RubarbPlugin
  @@options = {format: nil, respawn: nil}

  def self.options
    # todo: somehow differentiate that format takes a proc
    @@options
  end

  def self.add_option(name, settings = nil)
    @@options[name] = settings
  end

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

  def initialize(options)
    @@options.keys.each do |option|
      instance_variable_set("@#{option}", options.fetch(option, nil))
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
  add_option :color

  def initialize(options)
    super(options)
    @c = 0
  end
  
  def run
    @c += 1
  end
end

class Script < RubarbPlugin
  add_option :exec

  def run
    process.gets || begin
      process.close
      nil # returning this nil is killing the cache.  it'd be nice to get another 'respawn ; process' in here without calling our own respawn.
    end
  end

  def respawn
    still_running? ? 0 : super
  end

  private

  def still_running?
    !(@process.nil? || @process.closed?)
  end

  def process
    @process = nil if (@process && @process.closed?)
    @process ||= IO.popen(@exec) # how about if it crashes?  
  end 
end 

class Clock < RubarbPlugin
  def run
    Time.now
  end
end
