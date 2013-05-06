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

application "mkf_production" do
  path "/var/apps/mkf/production"
  owner "rails"
  group "rails"

  repository "git://github.com/meinekleinefarm/shop.git"
  revision "master"

  # Apply the rails LWRP from application_ruby
  rails do
    bundler true
    # Rails-specific configuration. See the README in the
    # application_ruby cookbook for more information.
    # database do
    #   database "redmine"
    #   username "redmine"
    #   password "awesome_password"
    # end
  end

  nginx_load_balancer do
#    only_if { node['roles'].include?('application') }
    application_server_role 'application'
    server_name 'shop.meinekleinefarm.org'
    application_port 8080
  end

  # Apply the unicorn LWRP, also from application_ruby
  unicorn do
    # unicorn-specific configuration.
    bundler true
    worker_processes 10
    worker_timeout 30
  end
end