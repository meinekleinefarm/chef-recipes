#
# Cookbook Name:: mkf
# Recipe:: default
#
# Copyright 2013, MeineKleineFarm UG
#
# All rights reserved - Do Not Redistribute
#
gem_package "ruby-shadow"
gem_package "bundler"

include_recipe "users"
users_manage "users" do
  group_id 100
  action :create
end

users_manage "sudo" do
  group_id 27
  action :create
end

db_connection = {
  :host => "127.0.0.1",
  :port => 5432,
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

postgresql_database_user "mkf_backend" do
  connection db_connection
  password "LLQ6tMY8ewpXHj"
  database_name 'mkf_backend'
  # privileges [:select,:update,:insert,:delete]
  action :create
end

postgresql_database "mkf_backend" do
  connection db_connection
  owner "mkf_backend"
  action :create
end

application "mkf_backend" do
  path "/var/apps/mkf/backend"
  owner "rails"
  group "rails"

  repository "https://github.com/christoph-buente/mkf.git"
  deploy_key '/home/rails/.ssh/mkf_deploy_user'
  revision "master"

  # Keep the release for debugging
  rollback_on_error false
  # action :force_deploy
  action :deploy

  migrate true

  create_dirs_before_symlink  ["tmp"]
  purge_before_symlink        ["log", "tmp/pids", "public/system"]
  symlink_before_migrate      "config/database.yml" => "config/database.yml", "config/memcached.yml" => "config/memcached.yml"
  symlinks                    "system" => "public/system", "pids" => "tmp/pids", "log" => "log"

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
    precompile_assets true

    database do
      adapter "postgresql"
      host "127.0.0.1"
      port 5432
      encoding "utf8"
      reconnect false
      database "mkf_backend"
      username "mkf_backend"
      password "LLQ6tMY8ewpXHj"
      pool 10
    end
  end

  # Apply the unicorn LWRP, also from application_ruby
  unicorn do
    # unicorn-specific configuration.
    bundler true
    worker_processes 2
    worker_timeout 30
    port '8090'
  end

  memcached do
    role "memcached_master"
    options do
      ttl 1800
      memory 256
    end
  end

  nginx_load_balancer do
#    only_if { node['roles'].include?('application') }
    application_server_role 'application'
    server_name 'backend.meinekleinefarm.org'
    application_port 8090
    template 'mkf_backend.conf.erb'
  end

end