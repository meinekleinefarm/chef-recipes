package "smartmontools"

cookbook_file "/etc/munin/plugin-conf.d/disks.conf" do
  mode 0644
  owner "root"
  group "root"
  source "disks.conf"
  action :create_if_missing
  notifies :restart, 'service[munin-node]'
end

munin_plugin "hddtemp_smartctl"
munin_plugin "diskstats"
munin_plugin "df"
munin_plugin "df_abs"


%w{sda sdb}.each do |disk|
  munin_plugin "smart_" do
    plugin "smart_#{disk}"
  end
end
