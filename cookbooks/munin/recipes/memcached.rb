include_recipe "perl"

cpan_module "Cache::Memcached"

%w(
  memcached_bytes_
  memcached_connections_
  memcached_hits_
  memcached_items_
  memcached_requests_
  memcached_responsetime_
  memcached_traffic_
).each do |plugin_name|
  munin_plugin plugin_name do
    plugin "#{plugin_name}#{node[:ipaddress].gsub('.','_')}_#{node[:memcached][:port]}"
    create_file true
  end
end