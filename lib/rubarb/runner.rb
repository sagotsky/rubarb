class Runner
  attr_accessor :name
  attr_reader :io_read

  # respawn or options seems nice, but is respawn really always option number one?  a shell script that I don't expect to respawn would have a file name come first.
  def initialize(rubarb, name, respawn_or_options = nil, &block)
    @name = name
    @token = name # unless otherwise specified
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
    klass = Object.const_get("#{name.capitalize}")
    return unless klass.superclass == RubarbPlugin
    options = if block
      #MetaConfigReader.new(klass.options).parse(block)
      InstanceVarConfigReader.parse(block)
    end 

    plugin = klass.new(options)
  end 
end
