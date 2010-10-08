cached_plugin 'exception_notifier', 'git://github.com/rails/exception_notification.git'

gsub_file 'app/controllers/application_controller.rb', /^class ApplicationController < ActionController::Base$/, <<-CODE
class ApplicationController < ActionController::Base
  include ExceptionNotifiable
CODE

gsub_file 'config/environment.rb', /^end$/, <<-CODE
end

ExceptionNotifier.exception_recipients = %w(#{ERROR_EMAIL})
ExceptionNotifier.sender_address = %("#{APPLICATION.upcase} Error" <#{SYSTEM_SENDER_EMAIL}>)
ExceptionNotifier.email_prefix = '[#{APPLICATION.upcase}] '
CODE