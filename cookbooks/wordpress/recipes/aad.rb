include_recipe "nginx"

template "adoptaday" do
  path "#{node['nginx']['dir']}/sites-available/adoptaday.net"
  source "adoptaday.conf.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :reload, "service[nginx]"
end

nginx_site "adoptaday.net"
