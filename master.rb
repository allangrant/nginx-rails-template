APPLICATION = File.split(root).last                          # The application name is whatever was provided after "rails" command
TEMPLATE_PATH = File.split(template).first

ERROR_EMAIL             = "pheonix@gmail.com"                # Address that exception_notifier should send error reports to
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
# Using cached_plugin, you rewrite your plugin include paths to point to local clones of their git repositories.
# Why? To speed up creating new rails projects or deploying via capistrano.  Since plugins are included as submodules,
# they have to be cloned each time capistrano deploys.  If pointing to remote git repositories, this can add minutes to
# the deploy time for each server.  By caching the plugins locally, this time is reduced to about a second.
#
# Example... Writing this:
#   cached_plugin 'exception_notifier', 'git://github.com/rails/exception_notification.git'
# Will either output this (if CACHED_PLUGINS_PATH is undefined):
#   plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true
# Or rewrite the link to this (if CACHED_PLUGINS_PATH is '~/rails_plugins' here):
#   plugin 'exception_notifier', :git => '~/rails_plugins/exception_notification', :submodule => true
#
# NOTE: If you use cached plugin paths, they'll have to match on your production servers for capistrano deploys to work.
#       It's a bit of a dirty hack, but works for me. Anyone have a better solution?
def cached_plugin(name, git_path)
  if USE_PLUGIN_SUBMODULES && !CACHED_PLUGINS_PATH.blank? && git_path =~ /(\/[^\/]+)$/
    git_path = CACHED_PLUGINS_PATH + $1.gsub(/.git$/, "")
  end
  plugin name, :git => git_path, :submodule => USE_PLUGIN_SUBMODULES
end

def template(file)
  load_template "#{TEMPLATE_PATH}/#{file}.rb"
end

def ask_with_default(question, default)
  input = ask("#{question} [#{default}]:")
  input.blank? ? default : input
end

SERVER_DOMAIN = ask_with_default("What is the production server domain for this project?", DEFAULT_DOMAIN)

git :init
template "compass"
template "mailer"
template "database"
template "scaffold"
template "haml-scaffold"
template "dependencies"
template "exception_notifier"
template "environment"
template "capistrano"
template "authlogic"
template "jquery" # Check to make sure that jquery.rb is downloading the jquery version & libraries you want.
template "clean"
template "git"
