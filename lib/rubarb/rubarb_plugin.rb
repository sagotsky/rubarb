class Rubarb::RubarbPlugin
  @@options = %i[render respawn]

  def self.options
    @@options.dup
  end

  # should have some validation.  some are options, some are required.  type checking wouldn't be bad either.  also defaults.
  def self.add_option(name)
    @@options << name
  end

  def run
    raise "Implement run in your RubarbPlugin class"
  end

  # turns output into string for display.  does it make sense for a plugin to override the cal to the lambda?
  def render(output)
    output = output.to_s.strip
    # or should this use a RubarbTemplate so we can eliminate the block args?
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




 




class Rubarb::FileReader < Rubarb::RubarbPlugin
end

class Rubarb::StdinReader < Rubarb::RubarbPlugin
end

#class Rubarb::Wm < Rubarb::RubarbPlugin
  # maybe this would be a better place than ewmhstatus to subscribe to wm notifications?
# end 

