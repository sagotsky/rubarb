#!/usr/bin/env ruby

require 'pry'
require 'ostruct'

class Rubarb
  def initialize
    @runners = []
    eval File.read('rubarbrc') # is eval still the best we can do?  
    @threads = runner_threads

    loop do 
      refresh_all_runners
      runner_output = @runners.map { |r| [ r.name, r.output ] }.to_h
      puts render_template(runner_output)
    end 
  end

  # maybe com cmd or something would be better?  run seems disingenous since it's just registering them.
  def run(*args, &block)
    # run/com/script should just be syntactic sugar for setting up the RubarbScript plugin
    @runners << Runner.new(self, *args, &block)
  end

  def bar(exec_string)
    # TODO figure out if rubarb should have an option to run a bar as well.  might be convenient to store it in the bar config.
  end

  def template(&block)
    @template = block
  end

  def render_template(token_values)
    token_values = OpenStruct.new token_values
    token_values.instance_exec(&@template)
  end

  # joining threads looks like it's the hard part of this script.  what can the threads possibly be doing?
  # * ruby method returning a string
  # * shell script continuously or repeatedly writing to stdout (no difference if we assume long processes should respawn)
  # * file/pipe reading in (is stdin a special case?)
  # since there's no one size fits all solution, can we at least get a one size fits all interface for different plugin types?
  # could IO.select watch file descriptors that were hidden in plugins?  seems like a leaky abstraction.  
  #   could IO.pipe be used to catch results from a ruby plugin?
  def runner_threads
    @runners.map do |runner|
      [runner.name, Thread.new { runner.run }]
    end.to_h
  end 

  def refresh_all_runners # update/refresh/?
    read_array, _, error_array = IO.select(@runners.map(&:io_read))
    @runners.find_all{|runner| read_array.include?(runner.io_read) }.each(&:refresh)
  end

  # is output going to need its own thread?

  def ls
    @runners.map &:to_s
  end

  #def exit
    #@runner.values.each &:join
  #end 
end

class Runner
  attr_accessor :name
  attr_reader :io_read

  RUNNER_ATTRS = %i[respawn format]
  RUNNER_ATTRS.each { |attr| attr_accessor attr }

  def initialize(rubarb, name, respawn_or_options = nil, &block)
    @name = name
    @rubarb = rubarb
    @output = ''
    @plugin = load_plugin(name)
    @io_read, @io_write = IO.pipe # seems like an implementation detail, but we need to call select on them later, so maybe it's relevant?

    ## registering options as attrs still seems reasonable (and wise if I want to allow type checking), but doing it in the class_eval didn't let the instance_exec work.  still not sure why.
    # @plugin.options.each do |option|
    #   self.class.class_eval do
    #     attr_accessor option
    #   end 
    # end

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
    loop do 
      # can we get options from the plugin into run at this point?
      # if optoins is a class method on the plugin, we can register them first, then get them from the dsl and init it with them.
      @io_write.puts @plugin.run
      sleep @respawn || 60
    end 
  end

  def kill

  end

  def refresh
    @output = @io_read.gets
  end

  def output
    #@output.to_s.strip
    @plugin.format @output
  end

  def to_s
    "#{@name} #{RUNNER_ATTRS.map{|a| [a, send(a)]}.to_h}"
  end

  private

  def load_plugin(name)
    begin 
      klass = Object.const_get("Rubarb::#{name.capitalize}")
      klass.new if klass.superclass == RubarbPlugin
    rescue 
      STDERR.puts "Could not find plugin: #{name}"
      exit(1)
    end 
  end 

  # and provide convenience setters for each of the attributes defined in the runner.  yes they can all be blocks right now...
  # TODO is this really wise?  using `respawn = 60` is still readable and not that much more verbose...
  # RUNNER_ATTRS.each do |attr|
  #   define_method attr do |value = nil, &block|
  #     var = "@#{attr}"
  #     instance_variable_set(var, value ) if value
  #     instance_variable_set(var, block ) if block
  #     instance_variable_get(var)
  #   end
  # end
end

class RubarbPlugin
  def run
    # should run wrap some internal runner thing?  then I could have other stuff trigger afterwards
    raise "Implement run in your RubarbPlugin class"
  end

  # turns output into string for display.
  def format(output)
    output.to_s.strip
  end
end

class Rubarb::Reader < RubarbPlugin
end

class Rubarb::StdinReader < RubarbPlugin
end

#class Rubarb::Wm < RubarbPlugin
  # maybe this would be a better place than ewmhstatus to subscribe to wm notifications?
# end 

class Rubarb::Counter < RubarbPlugin
  # this plugin is stupid, but a decent example if you want to watch the cache update on schedule
  def initialize
    @c = 0
  end
  
  def run
    @c += 1
  end
end

class Rubarb::Script < RubarbPlugin
  def initialize
    # PTY would probably be best way to get these as they're written
    @process = IO.popen('fortune ; sleep 1 ; fortune ; sleep 1 ; fortune', 'r')
  end

  def run
    puts @process.gets
  end
end 

class Rubarb::Clock < RubarbPlugin
  def run
    Time.now
  end
end

Rubarb.new
