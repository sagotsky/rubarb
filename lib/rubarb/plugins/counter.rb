# this plugin is stupid, but a decent example if you want to watch the cache update on schedule
class Rubarb::Counter < Rubarb::RubarbPlugin
  add_option :color

  def initialize(options)
    super(options)
    @counter = 0
  end
  
  def run
    @counter += 1
  end
end
