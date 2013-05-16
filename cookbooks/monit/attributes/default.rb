default[:monit][:notify_email]          = "webmaster@meinekleinefarm.org"

default[:monit][:poll_period]           = 60
default[:monit][:poll_start_delay]      = 10

default[:monit][:mail_format][:subject] = "$SERVICE $EVENT"
default[:monit][:mail_format][:from]    = "monit@#{node['fqdn']}"
default[:monit][:mail_format][:message]    = <<-EOS
Monit $ACTION $SERVICE at $DATE on $HOST: $DESCRIPTION.
Yours sincerely,
monit
EOS

default[:monit][:mailserver][:host] = "localhost"
default[:monit][:mailserver][:port] = nil
default[:monit][:mailserver][:username] = nil
default[:monit][:mailserver][:password] = nil
default[:monit][:mailserver][:password_suffix] = nil

default[:monit][:port] = 2812
default[:monit][:address] = "monit.meinekleinefarm.org"
default[:monit][:ssl] = true
default[:monit][:cert] = "/etc/ssl/certs/monit.pem"
default[:monit][:allow] = ["localhost"]
