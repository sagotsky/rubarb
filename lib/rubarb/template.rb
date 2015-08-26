module Rubarb
  class Template
    def initialize(&block)
      @template = block
    end

    def render(token_values = {})
      # todo: struct would be faster.  keys never change.  worth the trouble?
      token_values = OpenStruct.new token_values
      token_values.instance_exec(&@template)
    end 
  end
end 
