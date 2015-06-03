#!/usr/bin/env ruby

require 'pry'
require 'ostruct'
Dir.glob('rubarb/*').each { |file| require_relative file }
# also load up ~/.rubarb/plugins/*

class Rubarb
  def initialize
    @dispatchers = []
    eval File.read('../rubarbrc') # is eval still the best we can do?  
    @threads = dispatcher_threads
    @running = @threads.any?

    while @running do 
      refresh_dispatchers
      plugin_output = @dispatchers.map { |r| [ r.name, r.output ] }.to_h
      show @template.render(plugin_output)
    end 
  end

  # maybe com cmd or something would be better?  run seems disingenous since it's just registering them.
  def run(*args, &block)
    # run/com/script should just be syntactic sugar for setting up the RubarbScript plugin
    @dispatchers << PluginDispatcher.new(self, *args, &block)
  end

  def bar(exec_string = nil)
    @bar ||= IO.popen(exec_string, 'w')
  end

  def template(&block)
    @template = RubarbTemplate.new(block)
  end

  def show(text)
    (bar || STDOUT).puts text
  end

  def dispatcher_threads
    @dispatchers.map do |dispatcher|
      [dispatcher.name, Thread.new { dispatcher.run }]
    end.to_h
  end 

  def refresh_dispatchers 
    read_array, _, error_array = IO.select(@dispatchers.map(&:io_read))
    @dispatchers.find_all{|dispatcher| read_array.include?(dispatcher.io_read) }.each(&:refresh)
  end

  def ls
    @dispatchers.map &:to_s
  end

  #def exit
    #@dispatcher.values.each &:join
  #end 
end

Rubarb.new
