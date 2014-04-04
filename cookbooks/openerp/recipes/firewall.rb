# open standard openerp port
firewall_rule "openerp" do
  port_range 8069..8071
  protocol :tcp
  action :allow
  notifies :enable, "firewall[ufw]"
end

