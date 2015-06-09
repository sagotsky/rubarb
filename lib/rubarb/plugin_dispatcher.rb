class PluginDispatcher
  attr_accessor :token
  attr_reader :io_read

  ATTRS = %i[token]

  # should plugin finder be distinct from plugin dispatcher?
  def self.plugins
    all_plugins.map { |name| plugin_name(name) }
  end

  def self.plugin(name)
    plugin = all_plugins.find do |class_name| 
      plugin_name(class_name) == name
    end 
    Rubarb.const_get plugin
  end

  def initialize(rubarb, name, &block)
    @rubarb = rubarb
    @output = ''
    @io_read, @io_write = IO.pipe 

    plugin_opts = PluginDispatcher.plugin(name).options 
    cfg = ClassNameMethodConfigReader.new(plugin_opts + ATTRS)
    cfg.parse(block)
    @token = cfg.find(:token) || name
    @plugin = load_plugin(name, cfg.slice(plugin_opts).to_h)
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
    @plugin.render @output
  end

  private

  def load_plugin(name, options)
    PluginDispatcher.plugin(name).new(options)
  end 

  def self.all_plugins
    Rubarb.constants.select do |constant| 
      Rubarb.const_get(constant).is_a?(Class) && constant != :RubarbPlugin
    end
  end 

  def self.plugin_name(class_name)
    class_name.to_s.downcase.to_sym
  end

end
