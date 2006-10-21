# acts
require_plugin 'acts_as_messageable'
require_plugin 'acts_association_helper'

# validations
require_plugin 'validates_as_email'

# miscellaneous
require_plugin 'token_generator'

require 'acts_as_emailable'

ActiveRecord::Base.class_eval do
  include PluginAWeek::Acts::Emailable
end
