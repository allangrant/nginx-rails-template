gem 'authlogic', :source => 'http://gems.github.com'
gem 'collectiveidea-delayed_job', :lib => 'delayed_job', :source => 'http://gems.github.com'

file 'app/models/user_session.rb', <<-CODE
class UserSession < Authlogic::Session::Base
  generalize_credentials_error_messages true
end
CODE

file "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_create_users.rb", <<-CODE
class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :email,               :null => false
      t.string    :crypted_password,    :null => false
      t.string    :password_salt,       :null => false

      t.string    :persistence_token,   :null => false
      t.string    :single_access_token, :null => false
      t.string    :perishable_token,    :null => false
      t.integer   :login_count,         :null => false, :default => 0
      t.integer   :failed_login_count,  :null => false, :default => 0
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
CODE

file 'app/controllers/user_sessions_controller.rb', <<-CODE
class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:success] = "Login successful!"
      redirect_back_or_default account_path
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:success] = "Logout successful!"
    redirect_back_or_default login_path
  end
end
CODE

file 'app/controllers/users_controller.rb', <<-CODE
class UsersController < InheritedResources::Base
  defaults :singleton => true

  before_filter :require_user, :except => [:new, :create]
  before_filter :require_no_user, :only => [:new, :create]

  def create
    @user = User.new(params[:user])
    @user.email = params[:user][:email]
    if @user.save
      flash[:success] = 'Your account has been created!'
      Notifier.send_later :deliver_welcome, @user
      redirect_to(account_path)
    else
      render :action => "new"
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to account_path }
    end
  end  

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to login_path }
    end
  end

  private
  def resource
    @user ||= current_user
  end
end
CODE

gsub_file 'app/controllers/application_controller.rb', /^  private$/, <<-CODE
helper_method :current_user_session, :current_user
filter_parameter_logging :password, :password_confirmation

private

def current_user_session
  return @current_user_session if defined?(@current_user_session)
  @current_user_session = UserSession.find
end

def current_user
  return @current_user if defined?(@current_user)
  @current_user = current_user_session && current_user_session.record
end

def require_user
  unless current_user
    store_location
    flash[:notice] = "You must be logged in to access this page"
    redirect_to login_path
    return false
  end
end

def require_no_user
  if current_user
    store_location
    flash[:notice] = "You must be logged out to access this page"
    redirect_to account_path
    return false
  end
end

def store_location
  session[:return_to] = request.request_uri
end

def redirect_back_or_default(default)
  redirect_to(session[:return_to] || default)
  session[:return_to] = nil
end
CODE

file 'app/models/user.rb', <<-CODE
class User < ActiveRecord::Base
  acts_as_authentic
  attr_accessible :password, :password_confirmation

  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_reset_instructions(self)  
  end
  handle_asynchronously :deliver_password_reset_instructions!
end
CODE

file 'app/models/user_session.rb', <<-CODE
class UserSession < Authlogic::Session::Base
  generalize_credentials_error_messages true
end
CODE

file 'app/views/user_sessions/new.haml', <<-CODE
%h1 Login

- form_for @user_session, :url => {:action => :create} do |f|
  = f.error_messages
  = f.label :email
  %br
  = f.text_field :email
  %br
  = f.label :password
  %br
  = f.password_field :password
  %br
  %br
  = f.check_box :remember_me
  = f.label :remember_me
  %br
  %br
  = f.submit "Login"
  %br
  %br
  = link_to "Forgot Password", password_resets_path
CODE

file 'app/views/users/_form.haml', <<-CODE
= form.label :password
%br
= form.password_field :password
%br
= form.label :password_confirmation
%br
= form.password_field :password_confirmation
%br
CODE

file 'app/views/users/edit.haml', <<-CODE
%h1 Editing Account
- form_for(@user, :url => account_path) do |f|
  = f.error_messages
  = render :partial => "form", :object => f
  = f.submit "Save Changes"
.links
  = link_to 'View Account', account_path
  = link_to 'Delete Account', account_path, :confirm => 'Are you sure?', :method => :delete
CODE

file 'app/views/users/new.haml', <<-CODE
%h1 Create Account
- form_for(@user, :url => account_path) do |f|
  = f.error_messages
  = f.label :email
  %br
  = f.text_field :email
  %br
  = render :partial => "form", :object => f
  = f.submit "Create Account"
CODE

file 'app/views/users/show.haml', <<-CODE
%h1 Account Details
- content_tag_for :div, @user, :class => 'show' do
  .field Email:
  .value=h @user.email
    
.links
  = link_to 'Edit Account', edit_account_path
  = link_to 'Delete Account', account_path, :confirm => 'Are you sure?', :method => :delete
CODE

file 'app/views/shared/_header.haml', <<-CODE
= link_to 'Home', '/'
%span{:style => 'float: right;'}
  - if current_user
    =h "You are logged in as \#{current_user.email}."
    |
    = link_to 'user settings', edit_account_path
    |
    = link_to 'logout', logout_path
  - else
    = link_to 'login', login_path
    |
    = link_to 'register', register_path
CODE

file 'config/routes.rb', <<-CODE
ActionController::Routing::Routes.draw do |map|
  map.login '/', :controller => "user_sessions", :action => "new"
  map.logout 'logout', :controller => "user_sessions", :action => "destroy"
  map.register 'register', :controller => "users", :action => "new"
  map.resources :password_resets, :as => 'reset_password', :only => [:index, :create, :show, :update]
  map.resource :login, :controller => "user_sessions", :only => [:new, :create, :destroy]
  map.resource :account, :controller => "users"
end
CODE

file 'script/delayed_job', <<-CODE
#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))
require 'delayed/command'
Delayed::Command.new(ARGV).daemonize
CODE

require 'fileutils'
FileUtils.chmod 0755, 'script/delayed_job'

file "db/migrate/#{(Time.now.utc+1).strftime("%Y%m%d%H%M%S")}_create_delayed_jobs.rb", <<-CODE
class CreateDelayedJobs < ActiveRecord::Migration
  def self.up
    create_table :delayed_jobs, :force => true do |table|
      table.integer  :priority, :default => 0      # Allows some jobs to jump to the front of the queue
      table.integer  :attempts, :default => 0      # Provides for retries, but still fail eventually.
      table.text     :handler                      # YAML-encoded string of the object that will do work
      table.text     :last_error                   # reason for last failure (See Note below)
      table.datetime :run_at                       # When to run. Could be Time.now for immediately, or sometime in the future.
      table.datetime :locked_at                    # Set when a client is working on this object
      table.datetime :failed_at                    # Set when all retries have failed (actually, by default, the record is deleted instead)
      table.string   :locked_by                    # Who is working on this object (if locked)
      table.timestamps
    end

  end
  
  def self.down
    drop_table :delayed_jobs  
  end
end
CODE

file 'app/models/notifier.rb', <<-CODE
class Notifier < ActionMailer::Base
  SYSTEM_ACCOUNT = %("#{APPLICATION.titlecase}" <pheonix8d@gmail.com>)

  def welcome(user)
    subject       'Welcome to #{APPLICATION.titlecase}'
    recipients    user.email
    from          SYSTEM_ACCOUNT
    sent_on       Time.zone.now
    content_type  "multipart/alternative"
    part          :content_type => "text/plain", :body => render_message("welcome.text.plain", {})
    part          :content_type => "text/html", :body => render_message("welcome.text.html", {})
  end

  def password_reset_instructions(user)
    subject       "Password Reset Instructions"
    from          SYSTEM_ACCOUNT
    recipients    user.email
    sent_on       Time.zone.now
    body          :url => password_reset_url(user.perishable_token)
  end
end
CODE

file 'app/views/notifier/password_reset_instructions.erb', <<-CODE
A request to reset your password has been made. If you did not make this request, simply ignore this email. If you did make this request just click the link below:
 
<%= @url %>
 
If the above URL does not work try copying and pasting it into your browser. If you continue to have problems, please feel free to contact us.
CODE

file 'app/views/notifier/welcome.text.html.erb', <<-CODE
Welcome to #{APPLICATION.titlecase}!<br>
<br>
Login with your e-mail address and password at:<br>
<%= link_to login_url, login_url %>
CODE

file 'app/views/notifier/welcome.text.plain.erb', <<-CODE
Welcome to #{APPLICATION.titlecase}!

Login with your e-mail address and password at:
<%= login_url %>
CODE

file 'app/controllers/password_resets_controller.rb', <<-CODE
class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:show, :update]
  before_filter :require_no_user
  
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. Please check your email."
      redirect_to login_path
    else
      flash[:notice] = "No user was found with that email address."
      render :action => :index
    end
  end
  
  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password successfully updated."
      redirect_to account_url
    else
      render :action => :edit
    end
  end
 
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = "We're sorry, but we could not locate your account." +
        "If you are having issues try copying and pasting the URL " +
        "from your email into your browser or restarting the " +
        "reset password process."
      redirect_to login_path
    end
  end
end
CODE

file 'app/views/password_resets/index.haml', <<-CODE
%h1 Forgot Password
 
Fill out the form below and instructions to reset your password will be emailed to you:
%br
%br 
- form_tag password_resets_path do
  %label Email:
  %br
  = text_field_tag "email"
  %br
  %br
  = submit_tag "Reset my password"
  %br
  %br
  = link_to "Back to Login", login_path
CODE

file 'app/views/password_resets/show.haml', <<-CODE
%h1 Forgot Password: Change My Password

- form_for @user, :url => password_reset_path, :method => :put do |f|
  = f.error_messages
  = f.label :password
  %br
  = f.password_field :password
  %br
  %br
  = f.label :password_confirmation
  %br
  = f.password_field :password_confirmation
  %br
  %br
  = f.submit "Update my password and log me in"
CODE