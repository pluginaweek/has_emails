require 'config/boot'

Rails::Initializer.run do |config|
  config.plugin_paths << '..'
  config.plugins = %w(plugin_tracker state_machine has_messages validates_as_email_address has_emails)
  config.cache_classes = false
  config.whiny_nils = true
  config.action_mailer.delivery_method = :test
  config.action_controller.session = {:key => 'rails_session', :secret => 'd229e4d22437432705ab3985d4d246'}
end
