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
include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "1.9.3-p429"
rbenv_ruby "1.8.7-p371"

%w{bundler rake ruby-shadow}.each do |gem_name|
  rbenv_gem gem_name do
    ruby_version "1.9.3-p429"
  end

  rbenv_gem gem_name do
    ruby_version "1.8.7-p371"
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

application "mkf_production" do
  path "/var/apps/mkf/production"
  owner "rails"
  group "rails"

  repository "git://github.com/meinekleinefarm/shop.git"
  revision "master"
  deploy_key '~/.ssh/id_rsa'

  # Keep the release for debugging
  rollback_on_error false
  action :force_deploy
  #action :deploy

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

  memcached do
    role "memcached_master"
    options do
      ttl 1800
      memory 256
    end
  end

  nginx_load_balancer do
    ssl true
    ssl_certificate '/etc/ssl/certs/shop_meinekleinefarm_org.crt'
    ssl_certificate_key '/etc/ssl/private/shop_meinekleinefarm_org.key'
    application_server_role 'mkf_shop_application_server'
    server_name 'shop.meinekleinefarm.org'
    application_port 8080
    template 'mkf_production.conf.erb'
  end

end