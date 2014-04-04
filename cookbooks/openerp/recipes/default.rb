#
# Cookbook Name:: openerp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
gem_package "ruby-shadow"
gem_package "bundler"

include_recipe "users"
users_manage "openerp" do
  group_id 500
  action :create
end

include_recipe "database"
db_connection = {
  :host => "127.0.0.1",
  :port => 5432,
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

db_creds = Chef::EncryptedDataBagItem.load("passwords", "openerp_db")

postgresql_database "openerp" do
  connection db_connection
  action :create
end

postgresql_database "openerp" do
  connection db_connection
  sql "CREATE USER \"#{db_creds['username']}\" WITH CREATEDB PASSWORD '#{db_creds['password']}'"
  action :query
end

%w{python-dateutil python-docutils python-feedparser python-gdata
python-jinja2 python-ldap python-libxslt1 python-lxml python-mako python-mock python-openid
python-psycopg2 python-psutil python-pybabel python-pychart python-pydot python-pyparsing
python-reportlab python-simplejson python-tz python-unittest2 python-vatnumber python-vobject
python-webdav python-werkzeug python-xlwt python-yaml python-zsi}.each do |package_name|
  package package_name do
    action :install
  end
end

src_filename = "openerp-#{node['openerp']['server']['version']}-latest.tar.gz"
src_filepath = "#{Chef::Config['file_cache_path']}/#{src_filename}"
extract_path = "/opt/openerp"

remote_file src_filepath do
  source node["openerp"]["download"]["url"]
  action :create_if_missing
  owner "openerp"
  group "openerp"
end

bash 'extract_module' do
  user "openerp"
  group "openerp"
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar xzf #{src_filename} -C #{extract_path}
    chown -R openerp: #{extract_path}/openerp*
    mv #{extract_path}/openerp*/* #{extract_path}/
  EOH
  not_if "test -f #{extract_path}/openerp-server"
end

template "etc/openerp-server.conf" do
  source 'openerp-server.conf.erb'
  owner  'openerp'
  mode   '0640'
  variables(
    password: db_creds["password"],
    username: db_creds["username"],
    master_password: db_creds["master_password"]
  )
end

service "openerp" do
  supports :restart => true, :reload => true
end

cookbook_file "/etc/init.d/openerp" do
  source "openerp"
  owner "root"
  group "root"
  mode 0755
  action :create_if_missing
  notifies :restart, 'service[openerp]'
end

