NGINX RAILS TEMPLATE

INCLUDES:
- HAML & SASS, with Compass
- SASS layout based on blueprint with pixel-perfect baseline grid (http://www.alistapart.com/articles/settingtypeontheweb/)
- Clean layout for scaffolds
- Organized SASS file structure
- Authlogic with users, login screen, "forgot password" support, and welcome e-mail
- Capistrano deployment for nginx setup with serverside .erb file templates
- Delayed_job for mailers
- God for monitoring delayed_job
- Removes unnecessary files
- Sets up git and .gitignore
- Downloads jquery, jquery-ui, and desired jquery plugins
- Exception notifier
- Rails-footnotes
- will_paginate
- inherited resources

TO USE:
rails -m ~/path/to/this/project/master.rb -d mysql your_new_project_name

REQUIREMENTS:
Rails 2.3.8, SASS & HAML 3
For the Capistrano deployment to work without modifications, you need to:
- Use git
- Be able to ssh into your git repository server to create new repositories (or do this by hand for each project)
- Use nginx
- Have root access (sudo) on your production server, to deploy nginx .conf files, reboot servers, etc.

SETUP:
1. Edit master.rb and set constants at the top
2. Copy mailer.yml.example to mailer.yml and update with your SMTP information
3. Upload contents of server-templates into some directory on your server. Put the path to that dir into SERVER_TEMPLATES_PATH in master.rb.
4. Setup god
5. Upload nginx scripts or write your own.
6. Use it!

Detailed below:

1. Edit master.rb and set the constants at the top to values appropriate for your system:
ERROR_EMAIL             = "allan.grant@gmail.com"            # Address that exception_notifier should send error reports to
SYSTEM_SENDER_EMAIL     = "allan.grant.dev@gmail.com"        # Address that exception_notifier will send from
SERVER_TEMPLATES_PATH   = "/home/rails/templates"            # Path to .erb templates on server, from /server-templates
SERVER_DEPLOY_PATH      = "/home/rails"                      # Path to where all rails applications are deployed on server
SERVER_NGINX_APPS_PATH  = "/etc/nginx/sites-available"       # Path to nginx sites-available directory
GOD_PATH                = "/opt/ruby/bin/god"                # Path to god. Search for the truth. Enlightenment. 42
GIT_SERVER              = "git@allangrant.in"                # Git server, for git and scp.
GIT_ORIGIN              = "#{GIT_SERVER}:#{APPLICATION}.git" # Git origin, in scp format. user@server:path
GIT_ABS_PATH            = "/home/git/\#{application}.git"    # Where git repository should be created
SERVER_USER             = "rails"                            # Name of the user hosting rails on server
DEFAULT_DOMAIN          = "#{APPLICATION}.com"               # Default domain of the app, and server where capistrano will connect.

USE_PLUGIN_SUBMODULES   = true # Set to true to submodule plugins for easy updating, or false to freeze plugins at current version.
CACHED_PLUGINS_PATH     = "/var/rails_plugins" # READ BELOW: (only needed when USE_PLUGIN_SUBMODULES is true)
Using cached_plugin, you rewrite your plugin include paths to point to local clones of their git repositories.
Why? To speed up creating new rails projects or deploying via capistrano.  Since plugins are included as submodules,
they have to be cloned each time capistrano deploys.  If pointing to remote git repositories, this can add minutes to
the deploy time for each server.  By caching the plugins locally, this time is reduced to about a second.

Example... Writing this:
  cached_plugin 'exception_notifier', 'git://github.com/rails/exception_notification.git'
Will either output this (if CACHED_PLUGINS_PATH is undefined):
  plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true
Or rewrite the link to this (if CACHED_PLUGINS_PATH is '~/rails_plugins' here):
  plugin 'exception_notifier', :git => '~/rails_plugins/exception_notification', :submodule => true

NOTE: If you use cached plugin paths, they have to be the same on your dev & production servers for capistrano deploys to work.
      It's a bit of a dirty hack, but works for me. Anyone have a better solution?

2. Copy mailer.yml.example to mailer.yml and update with your SMTP information
Copy mailer.yml.example to mailer.yml and update with your development SMTP information.
Note: There is a mailer.yml.example file in the root directory of this repository and a mailer.yml in the server-templates directory. The file in the root is for the development server (when you first generate a project from the template) and the file in the server-templates directory is for the production server.

3. Upload contents of server-templates into some directory on your server. Put the path to that dir into SERVER_TEMPLATES_PATH in master.rb.
The capistrano deploy script uses templates to create database.yml, mailer.yml, and nginx site config files on the server, so the settings can be different from server to server if necessary.  Place the contents on your server, and put the path into the
SERVER_TEMPLATES_PATH constant in master.rb.  Edit the templates to fit your server configuration.

4. Setup god
Install god (http://god.rubyforge.org/) and create an init.d script.  One is provided in god-config directory of this project.
Set it to start automatically as root: update-rc.d god defaults 85 15
Create /etc/god.conf on your server, with contents similar to the god.conf file in god-config.
Make the the path in god.conf matches your rails application path.

5. Upload nginx scripts or write your own.
Inside nginx_scripts you'll find nxenable, nxdisable, nxrestart, and README.txt.  The scripts enable or disable nginx sites,
and restart the server.  This is encapsulated in scripts, so that sudo permission can be granted to those scripts if password-less
deploy is desired.  Here is what my sudoers file contains:
rails   ALL=NOPASSWD:/opt/ruby/bin/rake,/usr/bin/rake,/usr/local/bin/nxenable,/usr/local/bin/nxdisable,/opt/ruby/bin/god

Please these scripts somewhere in your path so they'll run.
Alternatively you could write your own versions, or change config/deploy.rb to enable/disable sites some other way.

6. Use it!
Create a new project:
rails -m ~/templates/master.rb -d mysql weblog

Deploy it:
cap deploy:setup
Note: It'll expect to be deployed at "#{APPLICATION}.com", which in this example would be weblog.com.  To change, edit DEFAULT_DOMAIN in master.rb in the template or config/deploy.rb in the app.

Now let's add posts:
./script/generate haml_scaffold posts title:string author:string body:text

And redeploy:
cap deploy:update
cap db:migrate


OPTIONAL ALIASES:
See ALIASES.txt for a list of aliases I use with this template, rails, and git.