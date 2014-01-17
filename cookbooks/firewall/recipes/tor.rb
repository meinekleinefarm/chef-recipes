firewall_rule "privoxy" do
  # enable privoxy over VPN
  source '10.8/16'
  port 8118
  protocol :tcp
  action :allow
  notifies :enable, "firewall[ufw]"
end
