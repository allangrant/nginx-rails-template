TEMPLATE_PATH = @template_path = File.split(template).first
require "#{TEMPLATE_PATH}/functions.rb"
APPLICATION = File.split(root).last                          # The application name is whatever was provided after "rails" command

ERROR_EMAIL             = "allan.grant@gmail.com"            # Address that exception_notifier should send error reports to
SYSTEM_SENDER_EMAIL     = "allan.grant.dev@gmail.com"        # Address that e-mails will send from
SERVER_USER             = "rails"                            # Name of the user hosting rails on server
SERVER_TEMPLATES_PATH   = "/home/rails/templates"            # Path to .erb templates on server, from /server-templates
DEFAULT_DEPLOY_PATH     = "/home/rails/#{APPLICATION}"       # Path to where all rails applications are deployed on server
SERVER_NGINX_APPS_PATH  = "/etc/nginx/sites-available"       # Path to nginx sites-available directory
GOD_PATH                = "/opt/ruby/bin/god"                # Path to god. Search for the truth. Enlightenment. 42
DEFAULT_GIT_SERVER      = "git@allangrant.in"                # Git server, for git and scp.
GIT_ABS_PATH            = "/home/git/\#{application}.git"    # Where git repository should be created
DEFAULT_SERVER_DOMAIN   = "#{APPLICATION}.com"               # Default domain of the app, and server where capistrano will connect.
GIT_SERVER              = ask_with_default("What is the git ssh username and server in format USER@HOST (ie: git@example.com): ", DEFAULT_GIT_SERVER)
GIT_ORIGIN              = "#{GIT_SERVER}:#{APPLICATION}.git" # Git origin, in scp format. user@server:path.
GIT_CAPISTRANO_FOLDER   = '#{application}.git'               # For git, give a string to be resolved later.
GIT_CAPISTRANO_REPO     = '#{git_server}:#{git_folder}'      # For git, give a string to be resolved later.
comment "Putting the git repository here: #{GIT_ORIGIN}"
SERVER_DOMAIN           = ask_with_default("What is the production server domain for this project?", DEFAULT_SERVER_DOMAIN)
DEFAULT_STAGING_DOMAIN  = "staging.#{SERVER_DOMAIN}"         # Default domain of the app, and server where capistrano will connect.
STAGING_DOMAIN          = ask_with_default("What is the staging server domain for this project?", DEFAULT_STAGING_DOMAIN)
REAL_HOST               = ask_with_default("What is the actual server host or IP to deploy to?", SERVER_DOMAIN)
DEPLOY_PATH             = ask_with_default("Where should the application reside?", DEFAULT_DEPLOY_PATH)
USE_PLUGIN_SUBMODULES   = ask_boolean("Do you want to use plugin submodules (Yes) or just install and freeze plugins at current version (No; recommended)?", false,
    :default => "NO: don't use submodules", :if_true => "(YES) Okay. We'll use \"git submodule add\".",
    :if_false => "(NO) Okay. We'll use script/plugin install instead of submodules, thereby freezing plugins to current version.")

if USE_PLUGIN_SUBMODULES
  # READ BELOW: (only needed when USE_PLUGIN_SUBMODULES is true)
  CACHED_PLUGINS_DEFAULT_OPTIONS = "/var/rails_plugins" # or use nil to default to no cached plugins.
  answer = ask_with_default("If you want to use cached plugins, enter path to cached plugins. Or say no (recommended).", CACHED_PLUGINS_DEFAULT_OPTIONS)
  CACHED_PLUGINS_PATH = (answer.downcase =~ /^(n|f|no|false)$/)? nil : answer
  puts CACHED_PLUGINS_PATH ? "Using cached plugin path: #{CACHED_PLUGINS_PATH}" : "Not using cached plugins."
end

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


git :init

template "mailer"
template "database"
template "compass"
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
