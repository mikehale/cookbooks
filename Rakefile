require 'rubygems'
require 'chef'
require 'json'


TOPDIR = File.expand_path(File.join(File.dirname(__FILE__), ".."))
TEST_CACHE = File.expand_path(File.join(TOPDIR, ".rake_test_cache"))
COMPANY_NAME = "Opscode, Inc."
SSL_EMAIL_ADDRESS = "cookbooks@opscode.com"
NEW_COOKBOOK_LICENSE = :apachev2

load 'chef/tasks/chef_repo.rake'
task :default => [ :test ]

desc "Build a bootstrap.tar.gz"
task :build_bootstrap do
  bootstrap_files = Rake::FileList.new
  %w(apache2 runit couchdb stompserver chef passenger ruby packages).each do |cookbook|
    bootstrap_files.include "#{cookbook}/**/*"
  end

  tmp_dir = "tmp"
  cookbooks_dir = File.join(tmp_dir, "cookbooks")
  rm_rf tmp_dir
  mkdir_p cookbooks_dir
  bootstrap_files.each do |fn|
    f = File.join(cookbooks_dir, fn)
    fdir = File.dirname(f)
    mkdir_p(fdir) if !File.exist?(fdir)
    if File.directory?(fn)
      mkdir_p(f)
    else
      rm_f f
      safe_ln(fn, f)
    end
  end

  chdir(tmp_dir) do
    sh %{tar zcvf ../bootstrap.tar.gz cookbooks}
  end
  rm_rf tmp_dir
end

# remove unnecessary tasks
%w{update install roles ssl_cert}.each do |t|
  Rake.application.instance_variable_get('@tasks').delete(t.to_s)
end

desc "Build a cookbooks.tar.gz containing all cookbooks"
task :build_cookbooks_package do
  cookbook_files = Rake::FileList.new
  Dir['**'].each do |cookbook|
    cookbook_files.include "#{cookbook}/**/*"
  end

  tmp_dir = "tmp"
  cookbooks_dir = File.join(tmp_dir, "cookbooks")
  rm_rf tmp_dir
  mkdir_p cookbooks_dir
  cookbook_files.each do |fn|
    f = File.join(cookbooks_dir, fn)
    fdir = File.dirname(f)
    mkdir_p(fdir) if !File.exist?(fdir)
    if File.directory?(fn)
      mkdir_p(f)
    else
      rm_f f
      safe_ln(fn, f)
    end
  end

  chdir(tmp_dir) do
    sh %{tar zcvf ../cookbooks.tar.gz cookbooks}
  end
  rm_rf tmp_dir
end

desc "Create metadata.json from metadata.rb"
task :metadata_all do
  sh %{knife cookbook metadata -a -o .}
end

desc "Create metadata.json from metadata.rb from a single cookbook"
task :metadata, :cookbook do |t, args|
  puts "knife cookbook metadata #{args.cookbook} -o #{File.dirname(__FILE__)}"
end
