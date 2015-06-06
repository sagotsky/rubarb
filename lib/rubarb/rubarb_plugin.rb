class RubarbPlugin
  @@options = {format: nil, respawn: nil}
  @@plugins = []

  def self.options
    # todo: somehow differentiate that format takes a proc
    @@options.dup
  end

  def self.add_option(name, settings = nil)
    @@options[name] = settings
  end

  # does this have to be here?  I don't want it getting inherited, but it needs to be on the plugin to register the ohters.  maybe the < self descendents isn't so bad after all
  def self.inherited(child)
    @@plugins << child.name
  end

  def self.plugins
    @@plugins.dup
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
    @counter = 0
  end
  
  def run
    @counter += 1
  end
end


class Script < RubarbPlugin
  add_option :exec

  def run
    process.gets # still might need to catch something here.   TODO try busted scripts
  end

  def respawn
    @process.eof? ? super : 0
  end

  private

  def process
    @process = @process.close if @process && @process.eof?
    @process ||= IO.popen(@exec) 
  end 
end 


class Clock < RubarbPlugin
  def run
    Time.now
  end
end
