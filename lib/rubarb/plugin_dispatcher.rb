class PluginDispatcher
  attr_accessor :name
  attr_reader :io_read

  # respawn or options seems nice, but is respawn really always option number one?  a shell script that I don't expect to respawn would have a file name come first.
  def initialize(rubarb, name, &block)
    # https://robots.thoughtbot.com/ruby-2-keyword-arguments
    @name = name
    @rubarb = rubarb
    @output = ''
    @plugin = load_plugin(name, block)
    @io_read, @io_write = IO.pipe # seems like an implementation detail, but we need to call select on them later, so maybe it's relevant?
  end

  def run
    loop do 
      @io_write.puts @plugin.run
      sleep @plugin.respawn
    end 
  end

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
