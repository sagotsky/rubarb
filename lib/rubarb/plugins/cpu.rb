module Rubarb
  class Cpu < RubarbPlugin
    IDLE = %i[idle io]
    NONIDLE = %i[user nice sys irq softirq steal]
    TOTAL = IDLE + NONIDLE

    def run
      @prev ||= cpu_info.first 
      info = cpu_info.first

      total = slice_and_sum(info, TOTAL)
      prev_total = slice_and_sum(@prev, TOTAL)
      idle = slice_and_sum(info, IDLE)
      prev_idle = slice_and_sum(@prev, IDLE)

      @prev = info
      (if total == prev_total
        1
      else 
        ((total - prev_total) - (idle - prev_idle)).to_f / (total - prev_total) 
      end * 100).to_i
    end
    
    private

    def slice_and_sum(list, fields)
      list.select{|k,v| fields.include? k}.values.reduce(:+)
    end 


    def cpu_info
      File.read('/proc/stat').split("\n").grep(/^cpu /).map do |cpu|
        fields = %i[cpu user nice sys idle io irq softirq steal guest guest_nice]
        fields.zip(cpu.split(' ').map(&:to_i)).to_h
      end
    end
  end



  class MultiCpu < RubarbPlugin
    def run
      cpu_info.map do |cpu, user, nice, sys, idle, io, irq, softirq, steal, guest, guest_nice|
        
        #http://stackoverflow.com/questions/23367857/accurate-calculation-of-cpu-usage-given-in-percentage-in-linux
        idle + iowait
      end
    end 

    private


    def cpu_info
      File.read('/proc/stat').split("\n").grep(/^cpu\d+/).map do |cpu|
        cpu.split ' '
      end
    end
  end
end
