#!/usr/bin/env ruby

require 'pry'

class Rubarb
  attr_accessor :runners

  def initialize
    @runners = []
    eval File.read('rubarbrc')
  end

  # maybe com cmd or something would be better?  run seems disingenous since it's just registering them.
  def run(*args, &block)
    @runners << Runner.new(*args, &block)
  end

  def ls
    @runners.map &:to_s
  end

end

class Runner
  attr_accessor :name
  RUNNER_ATTRS = %i[respawn format]
  RUNNER_ATTRS.each { |attr| attr_accessor attr }

  def initialize(name, respawn_or_options = nil, &block)
    @name = name
    @respawn = 'asdf'

    case respawn_or_options
    when Fixnum then @respawn = respawn_or_options
    when Hash 
      RUNNER_ATTRS.each do |attr|
        send attr, respawn_or_options.fetch(attr, nil)
      end 
    end

    instance_exec(&block) if block_given?
  end

  def to_s
    "#{@name} #{RUNNER_ATTRS.map{|a| [a, send(a)]}.to_h}"
  end

  private

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




bk = Rubarb.new
puts bk.ls
