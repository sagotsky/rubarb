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
      puts @template.render(runner_output)
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
    @template = RubarbTemplate.new(block)
  end

  def runner_threads
    @runners.map do |runner|
      [runner.name, Thread.new { runner.run }]
    end.to_h
  end 

  def refresh_all_runners # update/refresh/?
    read_array, _, error_array = IO.select(@runners.map(&:io_read))
    @runners.find_all{|runner| read_array.include?(runner.io_read) }.each(&:refresh)
  end

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

  # respawn or options seems nice, but is respawn really always option number one?  a shell script that I don't expect to respawn would have a file name come first.
  def initialize(rubarb, name, respawn_or_options = nil, &block)
    @name = name
    @rubarb = rubarb
    @output = ''
    @plugin = load_plugin(name, block)
    @io_read, @io_write = IO.pipe # seems like an implementation detail, but we need to call select on them later, so maybe it's relevant?

    # TODO: do we want to keep multiple syntaxes?  the refresh shorthand is nice.  dunno if the array one (or the dsl one) is better than the other.
  #  case respawn_or_options
  #   when Fixnum then @respawn = respawn_or_options
  #   when Hash 
  #     RUNNER_ATTRS.each do |attr|
  #       send attr, respawn_or_options.fetch(attr, nil)
  #     end 
  #   end
  end

  def run
    loop do 
      @io_write.puts @plugin.run
      sleep @plugin.respawn
    end 
  end

  # def kill
  # end

  def refresh
    @output = @io_read.gets
  end

  def output
    @plugin.format @output
  end

  private

  def load_plugin(name, block)
    begin 
      klass = Object.const_get("Rubarb::#{name.capitalize}")
      if klass.superclass == RubarbPlugin
        plugin = klass.new
        plugin.instance_exec(&block) if block
      end 
      plugin
    rescue 
      binding.pry  
      # shouldn't this be a catch so we can see where the above failed?
      # three errors: finding plugin, init'ing plugin, running block.  do them separately.
      STDERR.puts "Could not find plugin: #{name}"
      exit(1)
    end 
  end 
end

class RubarbTemplate
  def initialize(block)
    @template = block
  end

  def render(token_values = {})
    token_values = OpenStruct.new token_values
    token_values.instance_exec(&@template)
  end 
end

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
end

class Rubarb::Reader < RubarbPlugin
end

class Rubarb::StdinReader < RubarbPlugin
end

#class Rubarb::Wm < RubarbPlugin
  # maybe this would be a better place than ewmhstatus to subscribe to wm notifications?
# end 

# this plugin is stupid, but a decent example if you want to watch the cache update on schedule
class Rubarb::Counter < RubarbPlugin
  def initialize
    @c = 0
  end
  
  def run
    @c += 1
  end
end

class Rubarb::Script < RubarbPlugin
  def run
    process.gets || begin
      @process = nil
      process.gets
    end
  end

  private

  def process
    @process ||= IO.popen(@exec) # how about if it crashes?  
  end 
end 

class Rubarb::Clock < RubarbPlugin
  def run
    Time.now
  end
end

Rubarb.new
