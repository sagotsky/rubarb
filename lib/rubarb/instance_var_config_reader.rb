# config parser expriement for reading blocks with instance vars

=begin
run :counter do 
  @respawn = 1
  @color = 'red'
  @format = -> (txt) { txt*2 }
end 
=end

# catches instance vars from a block, returns them as an array
# the goal is to wrap the block in an object so it can't touch much else
class InstanceVarConfigReader
  def self.parse(block)
    obj = Object.new.tap {|obj| obj.instance_exec &block}
    obj.instance_variables.map do |var|
      [var.to_s.tr('@','').to_sym, obj.instance_variable_get(var)]
    end.to_h
  end
end

