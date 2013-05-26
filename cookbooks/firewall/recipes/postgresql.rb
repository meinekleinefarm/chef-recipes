# open standard postgresql port from outside ip address, enable firewall
firewall_rule "postgresql" do
  source node[:ipaddress]
  port 5432
  action :allow
  notifies :enable, "firewall[ufw]"
end

# open standard postgresql port from localhost, enable firewall
firewall_rule "postgresql" do
  source '127.0.0.1'
  port 5432
  action :allow
  notifies :enable, "firewall[ufw]"
end
