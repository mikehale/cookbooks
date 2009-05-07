if node[:fully_qualified_domain_name]
  node[:fqdn] = node[:fully_qualified_domain_name]
  node[:hostname], node[:domain] = node[:fqdn].split('.', 2)

  template "/etc/hosts" do
    source "hosts.erb"
    mode 0644
    owner "root"
    group "root"
  end

  template "/etc/hostname" do
    source "hostname.erb"
    mode 0644
    owner "root"
    group "root"
  end

  execute "set hostname" do
    command "/bin/hostname --file /etc/hostname"
    only_if { `/bin/hostname`.chomp != node[:hostname] }
  end
end