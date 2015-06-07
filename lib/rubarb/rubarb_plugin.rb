class Rubarb::RubarbPlugin
  @@options = %i[render respawn]

  def self.options
    # todo: somehow differentiate that format takes a proc
    @@options.dup
  end

  # should have some validation.  some are options, some are required.  type checking wouldn't be bad either.
  def self.add_option(name)
    @@options << name
  end

  def run
    raise "Implement run in your RubarbPlugin class"
  end

  # turns output into string for display.  does it make sense for a plugin to override the cal to the lambda?
  def render(output)
    output = output.to_s.strip
    output = @render.call(output) if @render
    output
  end

  def respawn
    @respawn || 60
  end

  def initialize(options)
    @@options.each do |option|
      instance_variable_set("@#{option}", options.fetch(option, nil))
    end
  end
end

class Rubarb::Reader < Rubarb::RubarbPlugin
end

class Rubarb::StdinReader < Rubarb::RubarbPlugin
end

#class Rubarb::Wm < Rubarb::RubarbPlugin
  # maybe this would be a better place than ewmhstatus to subscribe to wm notifications?
# end 

# this plugin is stupid, but a decent example if you want to watch the cache update on schedule
class Rubarb::Counter < Rubarb::RubarbPlugin
  add_option :color

  def initialize(options)
    super(options)
    @counter = 0
  end
  
  def run
    @counter += 1
  end
end


class Rubarb::Script < Rubarb::RubarbPlugin
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


class Rubarb::Clock < Rubarb::RubarbPlugin
  def run
    Time.now
  end
end
