set_unless[:passenger][:version] = "2.2.5"
set[:passenger][:root_path]      = "#{languages[:ruby][:gems_dir]}/gems/passenger-#{passenger[:version]}"
set[:passenger][:module_path]    = "#{passenger[:root_path]}/ext/apache2/mod_passenger.so"
set_unless[:passenger][:config]  = {}

set_unless[:languages][:ruby][:gem_bin] = languages[:ruby][:ruby_bin].gsub("ruby", "gem")
