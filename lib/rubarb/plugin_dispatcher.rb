module Rubarb
  class PluginDispatcher
    attr_accessor :token
    attr_reader :io_read

    ATTRS = %i[token]

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
      cfg = ConfigReader.new(plugin_opts + ATTRS)
      cfg.parse(block)
      @token = cfg.find(:token) || name
      @plugin = load_plugin(name, cfg.hash_slice(plugin_opts))
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
      @@all_plugins ||= begin
        Dir[File.join(File.dirname(__FILE__), 'plugins', '*.rb')].concat(Dir["#{Dir.home}/.rubarb/plugins/*.rb"]).each do |plugin|
          require plugin
        end

        Rubarb.constants.select do |constant| 
          Rubarb.const_get(constant).is_a?(Class) && constant != :RubarbPlugin
        end
      end 
    end 

    def self.plugin_name(class_name)
      class_name.to_s.downcase.to_sym
    end
  end
end 
