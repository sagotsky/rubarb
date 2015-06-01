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
    begin 
      klass = Object.const_get("#{name.capitalize}")
      if klass.superclass == RubarbPlugin
        plugin = klass.new
        binding.pry 
        #plugin.instance_exec(&block) if block
        # 
        # just playing with the object exec thing
        #c = InstanceVarConfigReader.parse(block) if block
        options = %i[respawn color format]
        c = MetaConfigReader.new(options)
        c.parse(block) if block
        binding.pry 
        # if this works, we can instnantiate off the block instead of setting the vars in the plugin instance
      end 
      plugin
    # rescue 
    #   binding.pry  
    #   # shouldn't this be a catch so we can see where the above failed?
    #   # three errors: finding plugin, init'ing plugin, running block.  do them separately.
    #   STDERR.puts "Could not find plugin: #{name}"
    #   exit(1)
    end 
  end 
end
