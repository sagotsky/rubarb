# the second metapgoramming version of InstanceVarConfigReader
# config parser expriement for reading blocks with instance vars
=begin
run :counter do 
  respawn  1
  color  'red'
  format -> (txt) { txt*2 } # does this way work or can it just be a block?
end 
=end

class MetaConfigReader2
  def initialize(options)
    eigenclass = class << self ; self end
    eigenclass.class_eval do 
      options.each do |option|
        opt = "@#{option}".to_sym
        define_method option do |*args|
          instance_variable_set opt, args.first if args.any?
          instance_variable_get opt
        end
      end
    end
  end

  def parse(&block)
    instance_exec &block
    puts foo
  end
end 

require 'pry'
foo = MetaConfigReader2.new([:foo])
bar = MetaConfigReader2.new([:bar])

foo.parse {
  foo nil
  foo 'baz'  
  #bar 'should not be'
}
