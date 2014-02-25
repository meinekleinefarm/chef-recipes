# open standard ssh port
firewall_rule "sshd" do
  port 22
  action :allow
  notifies :enable, "firewall[ufw]"
end

# open modified ssh port
firewall_rule "sshd" do
  port 22022
  action :allow
  notifies :enable, "firewall[ufw]"
end
