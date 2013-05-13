cookbook_file "/etc/munin/plugin-conf.d/nginx.conf" do
  mode 0644
  owner "root"
  group "root"
  source "nginx.conf"
  action :create_if_missing
  notifies :restart, 'service[munin-node]'
end

munin_plugin "nginx_request" do
  create_file true
end
munin_plugin "nginx_status" do
  create_file true
end
munin_plugin "nginx_memory" do
  create_file true
end

