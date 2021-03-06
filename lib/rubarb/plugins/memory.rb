module Rubarb
  class Memory < RubarbPlugin
    def run
      meminfo = File.read('/proc/meminfo')
      available = get_entry('MemAvailable', meminfo)
      total = get_entry('MemTotal', meminfo)
      (100 * (total - available) / total).to_i
    end

    private

    def get_entry(name, meminfo)
      meminfo.scan(/#{name}.*/).first.split(' ')[1].to_f rescue raise 'MemAvailable missing from /proc/meminfo.  Try a newer kernel.'
    end
  end
end
