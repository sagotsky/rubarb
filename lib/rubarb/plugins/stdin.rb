class Rubarb::Stdin < Rubarb::RubarbPlugin
  def run
    STDIN.gets
  end

  def respawn
    STDIN.eof? ? super : 0
  end

end
