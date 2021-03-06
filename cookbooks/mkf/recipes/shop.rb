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

rbenv_ruby "1.9.3-p484" do
  ruby_version "1.9.3-p484"
  global true
end

%w{bundler rake ruby-shadow pg unicorn}.each do |gem_name|
  rbenv_gem gem_name do
    ruby_version "1.9.3-p484"
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

certificate_manage "www_meinekleinefarm_org" do
  cert_path "/etc/ssl/"
  key_file "www.meinekleinefarm.org.key"
  chain_file "www.meinekleinefarm.org.crt"
#  nginx_cert true
end


application "mkf_production" do
  path "/var/apps/mkf/production"
  owner "rails"
  group "rails"

  repository "git://github.com/meinekleinefarm/shop.git"
  revision "production"
  deploy_key '~/.ssh/id_rsa'

  # Keep the release for debugging
  rollback_on_error false
  # action :force_deploy
  action :deploy

  migrate true

  create_dirs_before_symlink  ["tmp", "../../shared/pids", "../../shared/system"]
  purge_before_symlink        ["tmp/pids", "public/system"]
  symlink_before_migrate      "database.yml" => "config/database.yml",
                              "application.yml" => "config/application.yml",
                              "memcached.yml" => "config/memcached.yml",
                              "gattica.yml" => "config/gattica.yml",
                              "airbrake.yml" => "config/airbrake.yml",
                              "spree_chimpy.rb" => "config/initializers/spree_chimpy.rb",
                              "retentiongrid.rb" => "config/initializers/retentiongrid.rb"
  symlinks                    "system" => "public/system", "pids" => "tmp/pids", "spree" => "public/spree"

  before_symlink do
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
    symlink_logs true
    bundler true
    bundle_command "/opt/rbenv/shims/bundle"
    restart_command "sudo /etc/init.d/mkf_production reload"
    environment_name = "production"
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
    before_exec <<-EOF
  BUNDLE_GEMFILE='/var/app/mkf/production/current/Gemfile'
EOF
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
    pid '/var/apps/mkf/production/shared/pids/unicorn.pid'
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
    ssl_certificate '/etc/ssl/certs/www.meinekleinefarm.org.crt'
    ssl_certificate_key '/etc/ssl/private/www.meinekleinefarm.org.key'
    application_server_role 'mkf_shop_application_server'
    server_name 'meinekleinefarm.org'
    # application_socket ["/var/apps/mkf/production/shared/unicorn.sock"]
    application_port 8080
    template 'mkf_production.conf.erb'
  end

end

cron 'weekly-report' do
  weekday 'sun' # Run only on sundays
  hour    '23'
  minute  '52'
  user    'rails'
  command 'cd /var/apps/mkf/production/current/ && RAILS_ENV=production /opt/rbenv/shims/bundle exec rake report:weekly >> /var/apps/mkf/production/current/log/cron.log 2>&1'
end

cron 'payment-reminder' do
  minute '55'
  hour '9'
  user 'rails'
  command 'cd /var/apps/mkf/production/current/ && RAILS_ENV=production /opt/rbenv/shims/bundle exec rake payments:check_pending >> /var/apps/mkf/production/current/log/cron.log 2>&1'
end

cron 'sitemap.xml' do
  minute '0'
  hour '5'
  user 'rails'
  command 'cd /var/apps/mkf/production/current/ && RAILS_ENV=production /opt/rbenv/shims/bundle exec rake sitemap:refresh >> /var/apps/mkf/production/current/log/cron.log 2>&1'
end

cron 'retentiongrid' do
  minute '26'
  hour '14'
  user 'rails'
  command 'cd /var/apps/mkf/production/current/ && RAILS_ENV=production /opt/rbenv/shims/bundle exec rake retentiongrid:submit:customers retentiongrid:submit:products retentiongrid:submit:orders >> /var/apps/mkf/production/current/log/cron.log 2>&1'
end

cron 'mailchimp' do
  minute '42'
  hour '22'
  user 'rails'
  command 'cd /var/apps/mkf/production/current/ && RAILS_ENV=production /opt/rbenv/shims/bundle exec rake spree_chimpy:orders:sync spree_chimpy:users:sync spree_chimpy:users:segment >> /var/apps/mkf/production/current/log/cron.log 2>&1'
end

cron 'maintenance' do
  minute '49'
  hour '23'
  user 'rails'
  command 'cd /var/apps/mkf/production/current/ && RAILS_ENV=production /opt/rbenv/shims/bundle exec rake spree_chimpy:orders:sync spree_chimpy:users:sync spree_chimpy:users:segment >> /var/apps/mkf/production/current/log/cron.log 2>&1'
end

