certificate_manage "monit" do
  cert_path "/etc/ssl/"
  cert_file "#{node[:monit][:address]}.pem"
end

file "#{node[:monit][:cert]}" do
  mode 0600
end

package "monit"

sysadmins = search(:users, 'groups:sysadmin')

template "/etc/monit/htpasswd.users" do
  source "htpasswd.users.erb"
  owner "root"
  group "root"
  mode 0600
  variables(
    :sysadmins => sysadmins
  )
end

if platform?("ubuntu")
  cookbook_file "/etc/default/monit" do
    source "monit.default"
    owner "root"
    group "root"
    mode 0644
  end
end

service "monit" do
  action [:enable, :start]
  enabled true
  supports [:start, :restart, :stop]
end

directory "/etc/monit/conf.d/" do
  owner  'root'
  group 'root'
  mode 0755
  action :create
  recursive true
end

template "/etc/monit/monitrc" do
  owner "root"
  group "root"
  mode 0700
  source 'monitrc.erb'
  notifies :restart, resources(:service => "monit"), :delayed
end
