APPLICATION ||= File.split(root).last

capify!

file 'config/deploy.rb', <<-CODE
require 'fileutils'
set :application, "#{APPLICATION}"
set :domain, "#{SERVER_DOMAIN}"

set :repository,  "#{GIT_ORIGIN}"
server domain, :app, :web, :db, :primary => true
set :deploy_to, "#{SERVER_DEPLOY_PATH}/\#{domain}"
set :template_dir, "#{SERVER_TEMPLATES_PATH}" # where you have database.yml, mailer.yml, and nginx-site.conf.erb
set :nginx_conf, "#{SERVER_NGINX_APPS_PATH}/\#{domain}.conf"
set :user, "#{SERVER_USER}"
set :scm, :git

set :use_sudo, false
default_run_options[:pty] = true

def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e \#{full_path} ]; then echo 'true'; fi").strip
end

def read_remote(location)
  tmp = "~tmp-\#{rand(9999999)}"
  get(location, tmp)
  file = File.read(tmp)
  FileUtils.rm(tmp)
  return file
end

def sudo_put(data, target)
  tmp = "\#{shared_path}/~tmp-\#{rand(9999999)}"
  put data, tmp
  on_rollback { run "rm \#{tmp}" }
  sudo "cp -f \#{tmp} \#{target} && rm \#{tmp}"
end

def rake(command, options={})
  sudo_option = options[:sudo] ? "sudo" : ""
  ignore_output = options[:ignore_output] ? ";true" : ""
  path = options[:path] || release_path
  run "cd \#{path} && \#{sudo_option} rake RAILS_ENV=production \#{command}\#{ignore_output}"
end

def god(command)
  sudo "/opt/ruby/bin/god \#{command} \#{application}"
end

namespace :deploy do
  desc "Start the server"
  task :start do
    sudo "nxenable \#{domain}"
    god :start
  end
  desc "Stop the server"
  task :stop do
    sudo "nxdisable \#{domain}"
    god :stop
  end
  desc "Restart the server"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "\#{try_sudo} touch \#{File.join(current_path,'tmp','restart.txt')}"
    god :restart
  end
  desc "Completely remove deployment from the server"
  task :destroy do
    stop
    sudo "rm -f \#{nginx_conf}"
    update_code unless remote_file_exists?(current_path)
    rake "db:drop", :path => current_path, :ignore_output => true
    run "rm -rf \#{deploy_to}"
    god :stop
    god :remove
  end
  desc "Update, load schema, and start the server"
  task :cold do       # Overriding the default deploy:cold
    update
    load_schema       # My own step, replacing migrations.
    start
  end
  task :load_schema, :roles => :app do
    rake "db:create"
    # if remote_file_exists?(release_path + '/db/schema.rb')
    #   rake "db:schema:load"
    # else
      rake "db:migrate"
    # end
  end
  task :verify_setup do
    unless remote_file_exists?(deploy_to)
      setup
      set :new_setup, true
    else
      set :new_setup, false
    end
  end
  task :finish_new_deploy do
    if new_setup
      load_schema
      start
      sudo "#{GOD_PATH} load \#{current_path}/config/god/*.rb"
    end
  end
  task :touch_logs do
    run "touch \#{shared_path}/log/production.log"
    run "touch \#{shared_path}/log/nginx-access.log"
    run "touch \#{shared_path}/log/nginx-error.log"
    run "touch \#{shared_path}/log/god.log"
  end
  task :setup_shared, :except => { :no_release => true } do
    run "mkdir -p \#{shared_path}/config"
    run "cp \#{template_dir}/mailer.yml \#{shared_path}/config"
  end
  task :symlink_shared, :except => { :no_release => true } do
    run "ln -nfs \#{shared_path}/config/mailer.yml \#{release_path}/config/mailer.yml"
  end
end
before "deploy:update", "deploy:verify_setup"
after "deploy:update", "deploy:finish_new_deploy"
after "deploy:setup", "deploy:touch_logs"
after "deploy:setup", "deploy:setup_shared"
after "deploy:finalize_update", "deploy:symlink_shared"

namespace :nginx do
  desc "Creates the Nginx site file"
  task :create_site do
    template = read_remote(template_dir + '/nginx-site.conf.erb')
    sudo_put(ERB.new(template).result(binding), nginx_conf)
  end
end
after "deploy:setup", "nginx:create_site"

namespace :db do
  task :setup, :except => { :no_release => true } do
    template = read_remote(template_dir + '/database.yml.erb')
    put ERB.new(template).result(binding), "\#{shared_path}/config/database.yml"
  end

  task :symlink, :except => { :no_release => true } do
    run "ln -nfs \#{shared_path}/config/database.yml \#{release_path}/config/database.yml"
  end
  
  task :migrate do
    rake "db:migrate", :path => current_path
  end
  task :reset do
    set :release_path, current_path
    rake "db:drop"
  end
end

after "db:reset",               "deploy:load_schema"  
after "deploy:setup_shared",    "db:setup"   unless fetch(:skip_db_setup, false)
after "deploy:finalize_update", "db:symlink"

namespace :gems do
  desc "Installs gems"
  task :install, :roles => :app do
    rake "gems:install", :sudo => true
  end
end
after "db:symlink", "gems:install"

namespace :util do
  task :remove_mkmf do
    `rm -rf mkmf.log`
  end
end
after "deploy:update_code", "util:remove_mkmf"

namespace :git do
  desc "Creates the git repository"
  task :create do
    `ssh #{GIT_SERVER} "mkdir #{GIT_ABS_PATH} && cd #{GIT_ABS_PATH} && git init --bare"`
    `git push origin master`
  end
  desc "Deletes the git repository"
  task :destroy do
    `ssh #{GIT_SERVER} "rm -rf #{GIT_ABS_PATH}"`
  end
  task :submodules do
    run "cd \#{release_path}; git submodule update --init"
  end
end
before "gems:install", "git:submodules"
before "deploy:setup", "git:create"
CODE