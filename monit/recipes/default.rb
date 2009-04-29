url = @node[:monit][:url]
tarball = url.split('/').last
name = tarball.split('.tar.gz').first

remote_file "/usr/local/src/#{tarball}" do
  source url
  not_if { File.exists?("/usr/local/src/#{tarball}") }
end

bash "install_monit" do
  commands = []
  commands << "cd /usr/local/src"
  commands << "tar -zxf #{tarball}"
  commands << "cd #{name}"
  commands << "./configure && make && make install"

  user "root"
  code commands.join(' && ')
  not_if { File.exists?("/usr/local/bin/monit") }
end

service "monit" do
  start_command "/sbin/start monit"
  stop_command "/sbin/stop monit"
  reload_command "monit reload"
  supports :start => true, :stop => true, :reload => true
end

template "/etc/event.d/monit" do
  source "monit.erb"
  variables({
    :monit => "/usr/local/bin/monit"
  })
end

bash "monit_services_dir" do
  code "mkdir -p /etc/monit/services"
  not_if{ File.exists?('/etc/monit/services') }
end

template "/etc/monit/monitrc" do
  source "monitrc.erb"
  variables({
    :fqdn => node[:fqdn],
    :hostname => node[:hostname]
  })
  notifies :reload, resources(:service => "monit")
end

bash "montrc_hardlink" do
  code "ln -f /etc/monit/monitrc /etc/monitrc"
  not_if{ File.exists?('/etc/monitrc') }
end

%w(apache mysql postfix sshd).each do |service|
  template "/etc/monit/services/#{service}" do
    source "service_#{service}.erb"
    notifies :reload, resources(:service => "monit")
  end
end

service "monit" do
  action :start
end
