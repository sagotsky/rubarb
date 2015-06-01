#!/usr/bin/env ruby

require 'pry'
require 'ostruct'
Dir.glob('rubarb/*').each { |file| require_relative file }

class Rubarb
  def initialize
    @runners = []
    eval File.read('../rubarbrc') # is eval still the best we can do?  
    @threads = runner_threads
    @running = true

    while @running do 
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



Rubarb.new
