I use these three bash scripts to enable/disable nginx sites and restart nginx.:
	nxrestart
	nxenable
	nxdisable

This functionality is encapsulated in scripts so that I can grant the rails user passwordless sudoer permissions them.  This is what I have in my /etc/sudoers:

rails   ALL=NOPASSWD:/opt/ruby/bin/rake,/usr/bin/rake,/usr/local/bin/nxenable,/usr/local/bin/nxdisable,/opt/ruby/bin/god

With this, I can run "cap deploy" without typing a password most of the time (except when deploying new sites for the first time).