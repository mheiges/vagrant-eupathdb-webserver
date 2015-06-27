Puppet::Type.type(:tcif_instance).provide(:ruby) do

  commands :make => "make", :instance_manager => "instance_manager"

  # Instance dir is present and instance is running
  def enabled?
    return  active_instance_dir_exists? && running?
  end

  def enabled_not_running?
    return active_instance_dir_exists?
  end

  # Instance dir is present with '_' name prefix and assumed not running
  def disabled?
    if inactive_instance_dir_exists? && active_instance_dir_exists?
      raise Puppet::Error,
        "Both active and inactive directories exist for " +
        "Tomcat instance #{resource[:name]}. I'm unable to set to disabled."
    end
    return inactive_instance_dir_exists?
  end

  def active_instance_dir_exists?
    return File.directory?( @resource['instances_dir'] + "/" + @resource[:name] )
  end

  def inactive_instance_dir_exists?
    return File.directory?( @resource['instances_dir'] + "/" + "_" + @resource[:name] )
  end

  # remove a tomcat instance by deleting its directory and contents.
  # If the instance is running it will be stopped before deletion.
  # If the instance is disabled (named with leading underscore) it will be 
  #  assumed to be already not running and its directory will be deleted.
  # If the instance does not exist, there is no action.
  def delete
    stop
    [ @resource['instances_dir'] + "/" + @resource[:name],
      @resource['instances_dir'] + "/" + "_" + @resource[:name]
    ].each do |dir|
      FileUtils.rm_rf(dir) if File.directory?(dir)
    end
  end

  def running?
    execpipe("#{command(:instance_manager)} status") do |out|
      out.each_line do |line|
        if line =~ /^#{@resource[:name]}\s+\d+/
          return true
        end
      end
    end
    return false
  end

  def start
    puts "Starting #{@resource[:name]}"
    return if running?
    cmd = [command(:instance_manager)]
    cmd += ["start"]
    cmd += [@resource[:name]]
    run(cmd)
  end

  # Stop a tomcat instance if it is present and running.
  # instance_manager does not support stopping an instance that is not enabled.
  # instance_manager does not support checking if a disable instance is running.
  def stop(force = true)
    return if ! enabled?
    return if ! running?
    puts "Stopping #{@resource[:name]}"
    cmd = [command(:instance_manager)]
    cmd += ["stop"]
    cmd += [@resource[:name]]
    cmd += ["force"] if force
    run(cmd)
 end

  # disable a tomcat instance by renaming with leading underscore (_).
  # If the instance is running it will be stopped before disabling.
  # If the instance does not exist, it will be created, then disabled.
  def disable
    return if disabled?
    if enabled?
      stop
    else
      create
    end
    Dir.chdir(@resource['instances_dir'])
    File.rename @resource[:name], "_" + @resource[:name]
  end

  # enable a disabled tomcat instance by renaming without leading
  # underscore (_). If the instance is not running it will be started.
  # If the instance does not exist, it will be created.
  def enable
    return if enabled?
    if disabled?
      Dir.chdir(@resource['instances_dir'])
      File.rename "_" + @resource[:name], @resource[:name]
    else
      create
    end
    start
  end

  def create
    return if active_instance_dir_exists? or inactive_instance_dir_exists?
    Dir.chdir(@resource['instances_dir'])
    cmd = [command(:make)]
    cmd += ["install"]
    cmd += ["INSTANCE=#{@resource[:name]}"]
    cmd += ["HTTP_PORT=#{@resource[:http_port]}"]
    cmd += ["AJP13_PORT=#{@resource[:ajp13_port]}"]
    cmd += ["JMX_PORT=#{@resource[:jmx_port]}"]
    cmd += ["TOMCAT_USER=#{@resource[:tomcat_user]}"]
    cmd += ["TEMPLATE=#{@resource[:template_ver]}"]
    if defined? @resource[:orcl_jdbc_path]
      cmd += ["ORCL_JDBC_PATH=#{@resource[:orcl_jdbc_path]}"]  
    end
    if defined? @resource[:pg_jdbc_path]
      cmd += ["PG_JDBC_PATH=#{@resource[:pg_jdbc_path]}"]  
    end
    run(cmd)
  end


  def run(cmd)
    execute(cmd)
  rescue Puppet::ExecutionFailure => detail
    raise Puppet::Error, "command returned non-zero for class '#{@resource.class.name}', name '#{@resource.name}': #{detail}", detail.backtrace
  end

end