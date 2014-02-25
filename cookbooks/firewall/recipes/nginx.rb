# open standard http port
firewall_rule "http" do
  port 80
  action :allow
  notifies :enable, "firewall[ufw]"
end

# open standard https port
firewall_rule "https" do
  port 443
  action :allow
  notifies :enable, "firewall[ufw]"
end
