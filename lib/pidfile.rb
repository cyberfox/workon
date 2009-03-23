class PidFile
  def self.with_pidfile(name)
    pidfilename = "#{Rails.root}/log/#{name}.pid"
    if File.exist? pidfilename
      old_pid = open(pidfilename).read
      unless old_pid.blank?
        puts "Murdering #{old_pid} for #{name} as it's still running."
        Process.kill(9, old_pid.to_i) unless old_pid.blank?
        sleep 1
      end
    end
    pidfile = open(pidfilename, 'w')
    pidfile.write(Process.pid.to_s)
    pidfile.close
    yield
    File.unlink pidfilename
  end
end
