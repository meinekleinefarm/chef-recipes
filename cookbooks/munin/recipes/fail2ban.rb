cookbook_file "/etc/munin/plugin-conf.d/fail2ban.conf" do
  mode 0644
  owner "root"
  group "root"
  source "fail2ban.conf"
  action :create_if_missing
  notifies :restart, 'service[munin-node]'
end

munin_plugin "fail2ban" do
  create_file true
end
