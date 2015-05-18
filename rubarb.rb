#!/usr/bin/env ruby

require 'pry'

class Rubarb
  attr_accessor :runners

  def initialize
    @runners = []
    eval File.read('rubarbrc') # is eval still the best we can do?  
  end

  # maybe com cmd or something would be better?  run seems disingenous since it's just registering them.
  def run(*args, &block)
    # run/com/script should just be syntactic sugar for setting up the RubarbScript plugin
    @runners << Runner.new(self, *args, &block)
  end

  def plugin(*args, &block)

  end

  def bar(exec_string)

  end

  def spawn_threads
    @runners.map do |runner|
      [runner.name, Thread.new { runner.run }]
    end.to_h

    # when a thread joins, do we respawn?  multiple lines of plugin output are confusing right now.  kind of a different paradigm than the continually reading script runner
  end

  # is output going to need its own thread?

  def ls
    @runners.map &:to_s
  end

end

class Runner
  attr_accessor :name
  attr_accessor :rubarb
  attr_accessor :plugin
  RUNNER_ATTRS = %i[respawn format]
  RUNNER_ATTRS.each { |attr| attr_accessor attr }

  def initialize(rubarb, name, respawn_or_options = nil, &block)
    @name = name
    @rubarb = rubarb
    @plugin = load_plugin(name)


    case respawn_or_options
    when Fixnum then @respawn = respawn_or_options
    when Hash 
      RUNNER_ATTRS.each do |attr|
        send attr, respawn_or_options.fetch(attr, nil)
      end 
    end

    instance_exec(&block) if block_given?
  end

  def run
    @plugin.run
  end

  def kill

  end

  def output

  end

  def to_s
    "#{@name} #{RUNNER_ATTRS.map{|a| [a, send(a)]}.to_h}"
  end

  private

  def load_plugin(name)
    begin 
      klass = Object.const_get("Rubarb::#{name.capitalize}")
    rescue 
      STDERR.puts "Could not find plugin: #{name}"
      exit(1)
    end 
    klass.new if klass.superclass === RubarbPlugin
  end 

  # and provide convenience setters for each of the attributes defined in the runner.  yes they can all be blocks right now...
  RUNNER_ATTRS.each do |attr|
    define_method attr do |value = nil, &block|
      var = "@#{attr}"
      instance_variable_set(var, value ) if value
      instance_variable_set(var, block ) if block
      instance_variable_get(var)
    end
  end
end

class RubarbPlugin
  def run
    # should run wrap some internal runner thing?  then I could have other stuff trigger afterwards
    raise "Implement run in your RubarbPlugin class"
  end
end

class Rubarb::Script < RubarbPlugin
end

class Rubarb::Reader < RubarbPlugin
end

class Rubarb::StdinReader < RubarbPlugin
end

class Rubarb::WM < RubarbPlugin
  # maybe this would be a better place than ewmhstatus to subscribe to wm notifications?
end

class Rubarb::Clock < RubarbPlugin
  def run
    Time.now
  end
end

binding.pry 
bk = Rubarb.new
bk.spawn_threads
#puts bk.ls
