cached_plugin 'action_mailer_optional_tls', 'git://github.com/collectiveidea/action_mailer_optional_tls.git'

initializer 'smtp.rb', <<-CODE
mailer_config = File.open("\#{RAILS_ROOT}/config/mailer.yml")
mailer_options = YAML.load(mailer_config)
ActionMailer::Base.smtp_settings = mailer_options
CODE


# First copy the example file, in case mailer.yml does not exist
run "cp #{TEMPLATE_PATH}/mailer.yml.example config/mailer.yml"
run "cp #{TEMPLATE_PATH}/mailer.yml.example config/mailer.yml.example"
# Now copy mailer.yml to overwrite. ...and go wash your hands.
run "cp #{TEMPLATE_PATH}/mailer.yml config/mailer.yml"
run "cp #{TEMPLATE_PATH}/mailer.yml config/mailer.yml.example"

file 'config/initializers/validators.rb', <<-CODE
require 'resolv'

# RFC822 Email Address Regex
# --------------------------
# Originally written by Cal Henderson. Translated to Ruby by Tim Fletcher, with changes suggested by Dan Kubb.
# c.f. http://iamcal.com/publish/articles/php/parsing_email/

EMAIL_FORMAT = begin
  qtext = '[^\\\\x0d\\\\x22\\\\x5c\\\\x80-\\\\xff]'
  dtext = '[^\\\\x0d\\\\x5b-\\\\x5d\\\\x80-\\\\xff]'
  atom = '[^\\\\x00-\\\\x20\\\\x22\\\\x28\\\\x29\\\\x2c\\\\x2e\\\\x3a-' +
    '\\\\x3c\\\\x3e\\\\x40\\\\x5b-\\\\x5d\\\\x7f-\\\\xff]+'
  quoted_pair = '\\\\x5c[\\\\x00-\\\\x7f]'
  domain_literal = "\\\\x5b(?:\#{dtext}|\#{quoted_pair})*\\\\x5d"
  quoted_string = "\\\\x22(?:\#{qtext}|\#{quoted_pair})*\\\\x22"
  domain_ref = atom
  sub_domain = "(?:\#{domain_ref}|\#{domain_literal})"
  word = "(?:\#{atom}|\#{quoted_string})"
  domain = "\#{sub_domain}(?:\\\\x2e\#{sub_domain})*"
  local_part = "\#{word}(?:\\\\x2e\#{word})*"
  addr_spec = "\#{local_part}\\\\x40\#{domain}"
  pattern = /\\A\#{addr_spec}\\z/
end

ActiveRecord::Base.class_eval do
  def self.validates_email_format_of(*attr_names)
    # Set the default params
    params = { :message => "isn't valid" }

    # Update defaults with any supplied values
    params.update(attr_names.extract_options!)
    
    validates_each(attr_names) do |record, attr_name, email|
      # Assumes e-mail will be validated by validates_presence_of, if required
      unless email.blank?
        # Validates the format of the e-mail address
        unless email =~ EMAIL_FORMAT
          record.errors.add(attr_name, params[:message])
        else
          domain = email.match(/\@(.+)/)[1]
          begin
            Resolv::DNS.open do |dns|
              @mx  = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
            end
          rescue NoMethodError # we're not connected to the internet, and get NoMethodError exception
            next # then don't validate it (assume it's valid)
          end
          found_mx = @mx.size > 0
          # Validates the MX record on the e-mail domain
          unless (found_mx)
            record.errors.add(attr_name, params[:message])
          end
        end
      end
    end
  end
end
CODE

file 'config/god/delayed_job.rb', <<-CODE
root = "\#{File.dirname(__FILE__)}/../.."

1.times do |num|
  God.watch do |w|
    w.name = "#{APPLICATION}-dj-\#{num}"
    w.group = "#{APPLICATION}"
    w.interval = 30.seconds
    w.start = "rake -f \#{root}/Rakefile RAILS_ENV=production jobs:work"

    w.uid = 'rails'
    w.gid = 'rails'
    w.log = "\#{root}/log/god.log"
 
    # retart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 200.megabytes
        c.times = 2
      end
    end
 
    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end
 
    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end
 
      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end
 
    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end
CODE

gsub_file 'Rakefile', "require 'tasks/rails'", %%
require 'tasks/rails'

begin
  require 'delayed_job'
  require 'delayed/tasks'

rescue LoadError
  STDERR.puts "Run `rake gems:install` to install delayed_job"
end
%


gsub_file 'config/environment.rb', /  config.time_zone = 'UTC'/, <<-CODE
  config.time_zone = 'Pacific Time (US & Canada)'
CODE

gsub_file 'config/environments/production.rb', "# config.threadsafe!", <<-CODE
# config.threadsafe!

config.action_mailer.default_url_options = {
  :host => 'www.#{APPLICATION}.com'
}
CODE

gsub_file 'config/environments/development.rb', "config.action_mailer.raise_delivery_errors = false", <<-CODE
config.action_mailer.raise_delivery_errors = false

config.action_mailer.default_url_options = {
  :host => 'localhost',
  :port => 3000
}
CODE