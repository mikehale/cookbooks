build_dependencies = %w(zlib1g-dev libssl-dev libreadline5-dev)
extra_gem_dependencies = %w(libmysqlclient15-dev postgresql-server-dev-8.3 libsqlite3-dev)
(build_dependencies + extra_gem_dependencies).each {|p| package p }

url = @node[:ruby_enterprise_edition][:url]
tarball = url.split('/').last
name = tarball.split('.tar.gz').first

bash "ensure build_dir" do
  code "mkdir -p /usr/local/src"
end

remote_file "/usr/local/src/#{tarball}" do
  source url
  not_if { File.exists?("/usr/local/src/#{tarball}") }
end

bash "extract_tarball" do
  commands = []
  commands << "cd /usr/local/src"
  commands << "tar -zxf #{tarball}"

  user "root"
  code commands.join(' && ')
  not_if { File.exists?("/usr/local/src/#{name}") }
end

bash "install_ruby_enterprise_edition" do
  prefix = "/opt/#{name}"
  commands = []
  commands << "cd /usr/local/src"
  commands << %(echo -en "\n\n\n\n" | #{name}/installer 2>&1 > /dev/null)

  user "root"
  code commands.join(' && ')
  not_if { File.exists?(prefix) }
end

bash "link_to_current_version" do
  code "ln -nfs /opt/#{name} /opt/ruby-enterprise"
  not_if { File.exists?('/opt/ruby-enterprise') && File.readlink('/opt/ruby-enterprise') == "/opt/#{name}"}
end

ruby "link_binaries_to_default_path" do
  code %(
    `ls /opt/ruby-enterprise/bin | xargs`.split(' ').each do |e|
      `ln -nfs /opt/ruby-enterprise/bin/\#{e} /usr/local/bin/\#{e}`
    end
  )
end
