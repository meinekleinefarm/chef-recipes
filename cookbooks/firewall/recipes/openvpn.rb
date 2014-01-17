# open standard ssh port
firewall_rule "openvpn" do
  port 1194
  protocol :udp
  action :allow
  notifies :enable, "firewall[ufw]"
end
