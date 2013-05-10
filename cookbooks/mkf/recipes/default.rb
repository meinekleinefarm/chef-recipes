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

postgresql_database_user "mkf_production" do
  connection db_connection
  password "foobar"
  database_name 'mkf_production'
  # privileges [:select,:update,:insert,:delete]
  action :create
end

postgresql_database "mkf_production" do
  connection db_connection
  owner "mkf_production"
  action :create
end

application "mkf_production" do
  path "/var/apps/mkf/production"
  owner "rails"
  group "rails"

  repository "git://github.com/meinekleinefarm/shop.git"
  revision "master"

  # Keep the release for debugging
  rollback_on_error false
  action :force_deploy

  migrate false

  symlinks 'production.log' => 'log/production.log'
  before_symlink do
    directory "#{new_resource.shared_path}/log" do
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
      database "mkf_production"
      username "mkf_production"
      password "foobar"
      pool 10
    end
  end

  # Apply the unicorn LWRP, also from application_ruby
  unicorn do
    # unicorn-specific configuration.
    bundler true
    worker_processes 2
    worker_timeout 30
    port '8080'
  end

  nginx_load_balancer do
#    only_if { node['roles'].include?('application') }
    application_server_role 'application'
    server_name 'shop.meinekleinefarm.org'
    application_port 8080
    template 'mkf_production.conf.erb'
  end

end