def whyrun_supported?
  true
end

use_inline_resources

action :create do
  if @current_resource.exists
    Chef::Log.info "Tomcat instance #{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource }") do
      create_tomcat_instance
    end
  end
end

action :start do
  if @current_resource.exists
    if is_started?(current_resource.name)
      Chef::Log.info "Tomcat instance #{ @new_resource } already started - nothing to do."
      new_resource.updated_by_last_action(false)
    else
      converge_by("Start #{ @new_resource }") do
        cmdStr = "/sbin/service tomcat start #{ current_resource.name }"
        execute cmdStr do
          user "root"
        end
        new_resource.updated_by_last_action(true)
      end
    end
  else
    Chef::Log.info "Tomcat instance #{ @new_resource } does not exist."
    new_resource.updated_by_last_action(false)
  end
end

action :stop do
  if @current_resource.exists
    if is_started?(current_resource.name)
      converge_by("Stop #{ @new_resource }") do
        cmdStr = "/sbin/service tomcat stop #{ current_resource.name }"
        execute cmdStr do
          user "root"
        end
        new_resource.updated_by_last_action(true)
      end
    else
      Chef::Log.info "Tomcat instance #{ @new_resource } already started - nothing to do."
      new_resource.updated_by_last_action(false)
    end
  else
    Chef::Log.info "Tomcat instance #{ @new_resource } does not exist."
    new_resource.updated_by_last_action(false)
  end
end

action :restart do
  if @current_resource.exists
    converge_by("Restart #{ @new_resource }") do
      cmdStr = "/sbin/service tomcat restart #{ current_resource.name }"
      execute cmdStr do
        user "root"
      end
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info "Tomcat instance #{ @new_resource } does not exist."
    new_resource.updated_by_last_action(false)
  end
end

action :deploy_app do
  if @current_resource.exists
    if !application_exists?(current_resource.application_name)
      converge_by("Deploying #{current_resource.application_name} to #{ @new_resource }") do
        deploy_application
        new_resource.updated_by_last_action(true)
      end
    else
      Chef::Log.info "Tomcat application #{current_resource.application_name} exists."
      new_resource.updated_by_last_action(false)
    end
  else
    Chef::Log.info "Tomcat instance #{ @new_resource } does not exist."
    new_resource.updated_by_last_action(false)
  end
end

def load_current_resource 
  @current_resource = Chef::Resource::WsiTomcatInstance.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.service_definitions(@new_resource.service_definitions)
  @current_resource.cors(@new_resource.cors)
  @current_resource.tomcat_home(@new_resource.tomcat_home)
  @current_resource.server_opts(@new_resource.server_opts)
  @current_resource.auto_start(@new_resource.auto_start)
  @current_resource.application_name(@new_resource.application_name)
  if instance_exists?(@current_resource.name)
    @current_resource.exists     = true
  end
end

def instance_exists?(name)
  Chef::Log.debug "Checking to see if Tomcat instance '#{name}' exists"
  instances_home = ::File.expand_path("instance", current_resource.tomcat_home)
  instance_home = ::File.expand_path(name, instances_home)
  ::File.exists?(instance_home) && ::File.directory?(instance_home)
end

def application_exists?(name)
  application_final_name = node["wsi_tomcat"]["instances"][current_resource.name]["application"][name]["final_name"]
  tomcat_home_dir        = node["wsi_tomcat"]["user"]["home_dir"]
  instances_dir          = ::File.expand_path("instance", tomcat_home_dir)
  instance_dir           = ::File.expand_path(current_resource.name, instances_dir)
  webapps_dir            = ::File.expand_path("webapps", instance_dir)
  war_name               = ::File.expand_path("#{application_final_name}.war", webapps_dir)
  
  ::File.exists?(war_name)
end

def is_started?(name)
  Chef::Log.debug "Checking to see if Tomcat instance '#{name}' is started"
  cmdStr = "/sbin/service tomcat status #{name}"
  cmd = Mixlib::ShellOut.new(cmdStr)
  matcher = Regexp.new("(#{name}).*(is running).*", Regexp::IGNORECASE)
  cmd.run_command
  matcher.match(cmd.stdout)
end

def deploy_application
  instance_name          = current_resource.name
  application_name       = current_resource.application_name
  application_url        = node["wsi_tomcat"]["instances"][instance_name]["application"][application_name]["url"]
  application_final_name = node["wsi_tomcat"]["instances"][instance_name]["application"][application_name]["final_name"]
  tomcat_user            = node["wsi_tomcat"]["user"]["name"]
  tomcat_group           = node["wsi_tomcat"]["group"]["name"]
  tomcat_home_dir        = node["wsi_tomcat"]["user"]["home_dir"]
  instances_dir          = ::File.expand_path("instance", tomcat_home_dir)
  instance_dir           = ::File.expand_path(instance_name, instances_dir)
  webapps_dir            = ::File.expand_path("webapps", instance_dir)
  war_name               = ::File.expand_path("#{application_final_name}.war", webapps_dir)
  
  Chef::Log.info("deploying #{application_name} from #{application_url}")
  
  remote_file war_name do
    source application_url
    owner tomcat_user
    group tomcat_group
    backup false
  end
end

def create_tomcat_instance
  name                  = current_resource.name
  service_definitions   = current_resource.service_definitions
  server_opts           = current_resource.server_opts
  tomcat_home           = node["wsi_tomcat"]["user"]["home_dir"]
  fqdn                  = node["fqdn"]
  cors                  = current_resource.cors
  auto_start            = current_resource.auto_start
  tomcat_user           = node["wsi_tomcat"]["user"]["name"]
  tomcat_group          = node["wsi_tomcat"]["group"]["name"]
  manager_archive_name  = node["wsi_tomcat"]["archive"]["manager_name"]
  archives_home         = ::File.expand_path("archives", tomcat_home)
  manager_archive_path  = ::File.expand_path(manager_archive_name, archives_home)
  instances_home        = ::File.expand_path("instance", tomcat_home)
  instance_home         = ::File.expand_path(name, instances_home)
  instance_webapps_path = ::File.expand_path("webapps", instance_home)
  instance_bin_path     = ::File.expand_path("bin", instance_home)
  tomcat_bin_path       = ::File.expand_path("bin", tomcat_home)
  instance_conf_path    = ::File.expand_path("conf", instance_home)
  tomcat_init_script    = "tomcat-#{name}"
  default_cors          = {
      :enabled          => true,
      :allowed          => { 
        :origins        => "*",
        :methods        => ["GET", "POST", "HEAD", "OPTIONS"],
        :headers        => ["Origin", "Accept", "X-Requested-With", "Content-Type", "Access-Control-Request-Method", "Access-Control-Request-Headers"]
      },
      :exposed_headers     => [],
      :preflight_maxage    => 1800,
      :support_credentials => true,
      :filter => "/*"
    }
  instance_conf_files   = [
    "catalina.policy",
    "catalina.properties",
    "logging.properties",
    "context.xml",
    "logging.properties",
    "server.xml",
    "tomcat-users.xml",
    "web.xml"
  ]
  
  Chef::Log.info "Creating Instance #{name}"
  
  Chef::Log.info "Creating Instance Directory #{instance_home}"
  directory instance_home do
    owner tomcat_user
    group tomcat_group
    action :create
  end
  
  # Create the required directories in the instance directory
  %w{bin conf lib logs temp webapps work}.each do |dir|
    Chef::Log.info "Creating Instance subdirectory #{dir}"
    directory ::File.expand_path(dir, instance_home) do
      owner tomcat_user
      group tomcat_group
      action :create
    end
  end
  
  # Make sure that all CORS values are set
  if cors["enabled"]
    cors = default_cors.merge(cors)
  end
  
  instance_conf_files.each do |tpl|
    Chef::Log.info "Creating configuration file #{tpl}"
    template ::File.expand_path(tpl, instance_conf_path) do
      owner tomcat_user
      group tomcat_group
      source "instances/conf/#{tpl}.erb"
      sensitive true
      variables(
        :version => node["wsi_tomcat"]["version"].split(".")[0],
        :disable_admin_users => node["wsi_tomcat"]["instances"][name]["user"]["disable_admin_users"],
        :tomcat_admin_pass => node["wsi_tomcat"]["instances"][name]["user"]["tomcat_admin_pass"],
        :tomcat_script_pass => node["wsi_tomcat"]["instances"][name]["user"]["tomcat_script_pass"],
        :tomcat_jmx_pass => node["wsi_tomcat"]["instances"][name]["user"]["tomcat_jmx_pass"],
        :service_definitions => service_definitions,
        :cors => cors
      )
    end
  end
  
  %w{start stop}.each do |bin_file|
    Chef::Log.info "Templating bin file #{bin_file}"
    template "#{tomcat_bin_path}/#{bin_file}_#{name}" do
      source "instances/bin/#{bin_file}.erb"
      owner tomcat_user
      group tomcat_group
      mode 0744
      variables(
      :instance_name => name,
      :tomcat_home => tomcat_home
      )
    end
  end
  
  template "#{instance_bin_path}/setenv.sh" do
    source "instances/bin/setenv.sh.erb"
    owner tomcat_user
    group tomcat_group
    mode 0744
  end
  
  template "#{instance_bin_path}/catalinaopts.sh" do
    source "instances/bin/catalinaopts.sh.erb"
    owner tomcat_user
    group tomcat_group
    variables(
    :server_opts => server_opts
    )
    mode 0744
  end
  
  template "Install #{tomcat_init_script} script" do
    path "/etc/init.d/#{tomcat_init_script}"
    source "instances/tomcat-initscript.sh.erb"
    owner "root"
    group "root"
    variables(
    :instance_name => name,
    :tomcat_home => tomcat_home
    )
    mode 0755
  end
  
  directory "Create heapdumps directory" do
    owner tomcat_user
    group tomcat_group
    path "#{tomcat_home}/heapdumps/#{fqdn}/#{name}"
    recursive true
  end
  
  execute "Create manager application for #{name}" do
    cwd instance_webapps_path
    user tomcat_user
    group tomcat_group
    command "/bin/tar -xvf #{manager_archive_path}"
    not_if ::File.exists?(::File.expand_path("manager", instance_webapps_path))
  end
  
  # TODO This can probably be symlinked to the base tomcat directory
  execute "Copy tomcat-juli to instance #{name}" do
    user tomcat_user
    group tomcat_group
    command "/bin/cp #{archives_home}/tomcat-juli.jar #{instance_bin_path}"
    not_if ::File.exists?(::File.expand_path("tomcat-juli.jar", instance_bin_path))
  end
  
  execute "Chkconfig the init script for this instance" do
    user "root"
    group "root"
    command "/sbin/chkconfig --level 234 #{tomcat_init_script} on"
    not_if "chkconfig | grep -q '#{tomcat_init_script}'"
  end
  
  execute "Start tomcat instance #{name}" do
    command "/bin/bash service tomcat start #{name}"
    user "root"
    group "root"
    only_if { auto_start }
  end
  new_resource.updated_by_last_action(true)
end


