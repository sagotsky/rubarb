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
  format { |txt| txt.capitalize }
}
=end 

# requires list of config options, makes a setter for each
class ClassNameMethodConfigReader
  attr_reader :config

  def method_missing(method_name, *args, &block)
    if respond_to?(method_name)
      @config << [method_name].concat(block_given? ? [block] : args)
    else 
      super
    end
  end

  def respond_to?(method_name)
    @capture.include?(method_name) 
  end

  def initialize(capture = [])
    @capture = capture.map(&:downcase).map(&:to_sym)
    @config = []
  end

  def parse(config)
    case config
    when Proc then self.instance_eval(&config)
    else self.instance_eval(config)
    end 
    self
  end

  def parse_file(file)
    parse File.read(file)
    self
  end
end


