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
    plugin "#{plugin_name}127_0_0_1_#{node[:memcached][:port]}"
    create_file true
  end
end