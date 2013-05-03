#
# Cookbook Name:: mkf
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
application "mkf_production" do
  path "/var/apps/mkf/production"
  owner "rails"
  group "rails"

  repository "https://github.com/meinekleinefarm/shop.git"
  revision "production"

  # Apply the rails LWRP from application_ruby
  rails do
    # Rails-specific configuration. See the README in the
    # application_ruby cookbook for more information.
    database do
      database "redmine"
      username "redmine"
      password "awesome_password"
    end
  end

  # Apply the passenger_apache2 LWRP, also from application_ruby
  unicorn do
    # Passenger-specific configuration.
    bundler true
    worker_processes = 10
    worker_timeout = 30
  end
end