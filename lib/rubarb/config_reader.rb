# Yet another metapgramming config reader
# Instead of using command/com/run to call a plugin and give it a block,
# this one does a define_method per plugin's class name.  That method
# automatically knows the plugin and will take a block.  Plus, the block will 
# be the only arugment so it should work with brackets instead of do/end

=begin
script_plugin {
  exec '/path/to/file'
  respawn 60
  token 'myscript'
  render { |txt| txt.capitalize }
}
=end 

# requires list of config options, makes a setter for each
module Rubarb
  class ConfigReader
    def initialize(options = [])
      @_config = []
      options.map(&:downcase).map(&:to_sym).each do |option|
        define_singleton_method option do |*args, &block|
          @_config << [option, [*args, block].compact]
        end
      end
    end

    def parse(config)
      case config
      when Proc then self.instance_eval(&config)
      else self.instance_eval(config)
      end 
    end

    def parse_file(file)
      parse File.read(file)
    end

    def find(key)
      value = @_config.to_h.fetch(key, nil)
      value ? value[0] : nil
    end

    def slice(keys)
      @_config.select { |key, value| keys.include? key }
    end

    def hash_slice(keys)
      slice(keys).map do |k,v| 
        [k, v.first]
      end.to_h
    end
  end
end 
