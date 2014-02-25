# open standard memcached port from outside ip address, enable firewall
firewall_rule "memcached" do
  source node[:ipaddress]
  port 11211
  action :allow
  notifies :enable, "firewall[ufw]"
end

# open standard memcached port from localhost, enable firewall
firewall_rule "memcached" do
  source '127.0.0.1'
  port 11211
  action :allow
  notifies :enable, "firewall[ufw]"
end