# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'digest/md5'

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'

  config.action_controller.perform_caching = true
  
  ROOT_URL = ""

  #config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => 'smtp.gmail.com',
    :port => 587,
    :authentication => :plain,
    :domain => 'clojuredocs.org',
    :user_name => 'contact@clojuredocs.org',
    :password => File.read('/etc/clojuredocs/mailer_password')
  }
  config.action_mailer.delivery_method = :activerecord

end
#ActionMailer::Base.smtp_settings = { :enable_starttls_auto => true }
#ActionMailer::Base.delivery_method = :activerecord
