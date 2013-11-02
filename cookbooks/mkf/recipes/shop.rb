#
# Cookbook Name:: mkf
# Recipe:: default
#
# Copyright 2013, MeineKleineFarm UG
#
# All rights reserved - Do Not Redistribute
#

include_recipe "users"
include_recipe "sudo"

gem_package "ruby-shadow"
gem_package "bundler"
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "1.9.3-p448" do
  ruby_version "1.9.3-p448"
  global true
end

%w{bundler rake ruby-shadow pg unicorn}.each do |gem_name|
  rbenv_gem gem_name do
    ruby_version "1.9.3-p448"
  end
end

include_recipe "users"
users_manage "users" do
  group_id 100
  action :create
end

users_manage "sudo" do
  group_id 27
  action :create
end

sudo 'shop' do
  user      "rails"    # or a username
  commands  ['/etc/init.d/mkf_production reload']
  nopasswd true
end

certificate_manage "shop" do
  cert_path "/etc/ssl/"
  key_file "shop.meinekleinefarm.org.key"
  chain_file "shop.meinekleinefarm.org.crt"
end

application "mkf_production" do
  path "/var/apps/mkf/production"
  owner "rails"
  group "rails"

  repository "git://github.com/meinekleinefarm/shop.git"
  revision "master"
  deploy_key '~/.ssh/id_rsa'

  # Keep the release for debugging
  rollback_on_error false
  # action :force_deploy
  action :deploy

  migrate true

  create_dirs_before_symlink  ["tmp"]
  purge_before_symlink        ["log", "tmp/pids", "public/system"]
  symlink_before_migrate      "database.yml" => "config/database.yml", "memcached.yml" => "config/memcached.yml"
  symlinks                    "system" => "public/system", "pids" => "tmp/pids", "log" => "log", "spree" => "public/spree"

  before_symlink do
    directory "#{new_resource.shared_path}/log" do
      owner new_resource.owner
      group new_resource.group
      mode '755'
      action :create
    end
    directory "#{new_resource.shared_path}/system" do
      owner new_resource.owner
      group new_resource.group
      mode '755'
      action :create
    end

    directory "#{new_resource.shared_path}/spree" do
      owner new_resource.owner
      group new_resource.group
      mode '755'
      action :create
    end

    directory "#{new_resource.shared_path}/pids" do
      owner new_resource.owner
      group new_resource.group
      mode '755'
      action :create
    end
  end

  # Apply the rails LWRP from application_ruby
  rails do
    # Rails-specific configuration. See the README in the
    # application_ruby cookbook for more information.

    bundler true
    bundle_command "/opt/rbenv/shims/bundle"
    restart_command "sudo /etc/init.d/mkf_production reload"
    precompile_assets true


    db_creds = Chef::EncryptedDataBagItem.load("passwords", "mkf_shop_db")

    database do
      adapter "postgresql"
      encoding "unicode"
      reconnect false
      database "mkf_production"
      username "mkf_production"
      password db_creds["password"]
      pool 50
    end
    # database_master_role "mkf_shop_database_server"
  end

  # Apply the unicorn LWRP, also from application_ruby
  unicorn do
    # unicorn-specific configuration.
    preload_app true
    before_fork <<-EOF
  # This option works in together with preload_app true setting
  # What it does is prevent the master process from holding
  # the database connection
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "/var/apps/mkf/production/shared/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
EOF

after_fork <<-EOF
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
EOF

    bundler true
    worker_processes 8
    worker_timeout 30
    port '8080'
    options :backlog => 2048
  end

  memcached do
    role "memcached_master"
    options do
      ttl 1800
      memory 256
    end
  end

  nginx_load_balancer do
    only_if { node['roles'].include?('mkf_shop_application_server') }
    ssl true
    ssl_certificate '/etc/ssl/certs/shop.meinekleinefarm.org.crt'
    ssl_certificate_key '/etc/ssl/private/shop.meinekleinefarm.org.key'
    application_server_role 'mkf_shop_application_server'
    server_name 'shop.meinekleinefarm.org'
    # application_socket ["/var/apps/mkf/production/shared/unicorn.sock"]
    application_port 8080
    template 'mkf_production.conf.erb'
  end

end