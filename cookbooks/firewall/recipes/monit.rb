# open custom monit web port
firewall_rule "http" do
  port 2812
  action :allow
  notifies :enable, "firewall[ufw]"
end
