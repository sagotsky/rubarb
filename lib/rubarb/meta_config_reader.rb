# the metapgoramming version of InstanceVarConfigReader
# config parser expriement for reading blocks with instance vars
=begin
run :counter do 
  respawn  1
  color  'red'
  format -> (txt) { txt*2 } # does this way work or can it just be a block?
end 
=end

class MetaConfigReader
  def method_missing(method_name, *args, &block)
    if responds_to?(method_name)
      @options[method_name] = args.first
    else 
      super
    end
  end

  def format(&block)
    @options[:format] = block
  end

  def responds_to?(method_name)
    @options.has_key? method_name
  end

  def initialize(options)
    # todo: look into casting, defaults
    # format(&block) doesn't seem to work with method_missing.  that's an argument for define_method
    @options = options.map{|o| [o, nil]}.to_h || {}
  end

  def parse(block)
    self.instance_exec(&block)
    @options
  end
end

