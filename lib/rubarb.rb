#!/usr/bin/env ruby

require 'rubarb/version'
require 'ostruct'
require 'pry'
require 'rubarb/plugin_dispatcher'
require 'rubarb/config_reader'
require 'rubarb/rubarb_plugin'
require 'rubarb/template'

module Rubarb
  RUBARB_CONF = %i[bar template]

  def self.new(file: "#{ENV['HOME']}/.rubarbrc", config: nil)
    config_options = PluginDispatcher.plugins + RUBARB_CONF
    cfg = ConfigReader.new(config_options)

    if config
      cfg.parse(config)
    else
      cfg.parse_file(file)
    end

    Manager.new(cfg)
  end 

  class Manager
    def initialize(cfg)
      @dispatchers = []

      cfg.slice(RUBARB_CONF).each do |attr, args|
        send attr, *args
      end

      cfg.slice(PluginDispatcher.plugins).each do |plugin, args|
        dispatch_plugin plugin, *args
      end

      @threads = dispatcher_threads
      @running = @threads.any?

      while @running do 
        refresh_dispatchers
        plugin_output = @dispatchers.map { |r| [ r.token, r.output ] }.to_h
        show @template.render(plugin_output)
      end 
    end

    def dispatch_plugin(name, block)
      @dispatchers << PluginDispatcher.new(self, name, &block)
    end

    def bar(exec_string = nil)
      @bar ||= IO.popen(exec_string, 'w') rescue nil
    end

    def template(block)
      @template = Template.new(&block)
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
      read_array, _, _ = IO.select(@dispatchers.map(&:io_read))
      @dispatchers.find_all do |dispatcher| 
        read_array.include?(dispatcher.io_read) 
      end.each(&:refresh)
    end

    def ls
      @dispatchers.map(&:to_s)
    end

    #def exit
      #@dispatcher.values.each &:join
      # also the bar.
    #end 
  end
end 
