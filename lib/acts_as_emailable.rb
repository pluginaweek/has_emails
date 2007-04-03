# acts
require 'acts_as_messageable'
require 'acts_association_helper'

# associations
require 'class_associations'

# validations
require 'validates_as_email'

# miscellaneous
require 'token_generator'

module PluginAWeek #:nodoc:
  module Acts #:nodoc:
    module Emailable
      def self.included(base) #:nodoc:
        base.extend(MacroMethods)
      end
      
      module MacroMethods
        # 
        def acts_as_emailable(*args, &extension)
          default_options = {
            :as => :emailable,
            :extend => EmailAddress::StateExtension
          }
          association_id, klass, options = create_acts_association(:email_address, default_options, *args, &extension)
          
          # Add associations for all emails the model has sent and received
          has_many  :received_emails,
                      :through => association_id
          has_many  :sent_emails,
                      :through => association_id
          
          # Add class-level email_addresses association
          plural_association_id = options[:count] == :many ? association_id : association_id.to_s.pluralize
          klass = class << self; self; end
          klass.class_eval do
            has_many  plural_association_id,
                        :as => options[:as]
          end
        end
      end
      
      module ClassMethods #:nodoc
      end
      
      module InstanceMethods
        # Contains all of the emails that have been sent and received
        def email_box
          @email_box ||= MessageBox.new(received_emails, sent_emails)
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include PluginAWeek::Acts::Emailable
end