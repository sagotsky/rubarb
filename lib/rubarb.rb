#!/usr/bin/env ruby

require 'pry'
require 'ostruct'

class Rubarb
  RUBARB_CONF = %i[bar template]
  def initialize
    @dispatchers = []
    config_options = PluginDispatcher.plugins + RUBARB_CONF
    rc = ClassNameMethodConfigReader.new(config_options)
    config = rc.parse_file('../rubarbrc').config

    config.each do |key, *values|
      if RUBARB_CONF.include? key
        self.send key, *values
      else 
        plugin key, *values
      end 
    end

    @threads = dispatcher_threads
    @running = @threads.any?

    while @running do 
      refresh_dispatchers
      plugin_output = @dispatchers.map { |r| [ r.token, r.output ] }.to_h
      show @template.render(plugin_output)
    end 
  end

  def plugin(name, block)
    @dispatchers << PluginDispatcher.new(self, name, &block)
  end

  def bar(exec_string = nil)
    @bar ||= IO.popen(exec_string, 'w') rescue nil
  end

  def template(block)
    @template = RubarbTemplate.new(&block)
  end

  def show(text)
    (bar || STDOUT).puts text
  end

  def dispatcher_threads
    @dispatchers.map do |dispatcher|
      [dispatcher.token, Thread.new { dispatcher.run }]
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
    # also the bar.
  #end 
end

Dir.glob('rubarb/*').each { |file| require_relative file }

Rubarb.new
