# acts
require 'acts_as_messageable'
require 'acts_association_helper'

# validations
require 'validates_as_email'

# miscellaneous
require 'token_generator'

require File.join(File.dirname(__FILE__), '..', 'app', 'mailer', 'application_mailer')

module PluginAWeek #:nodoc:
  module Acts #:nodoc:
    module Emailable
      def self.included(base) #:nodoc:
        base.extend(MacroMethods)
      end
      
      module MacroMethods
        #
        #
        def acts_as_emailable(*args, &extension)
          create_options = {
            :foreign_key_name => :emailable,
            :extend => EmailAddress::StateExtension
          }
          options, email_address_class, association_id = create_acts_association(:email_address, create_options, {}, *args, &extension)
          
          message_options = {:class_name => 'Email'}
          message_options[:cross_model_emailing] = options[:cross_model_emailing] if options[:cross_model_emailing]
          email_address_class.class_eval do
            acts_as_messageable message_options
          end
          
          # Add support for messageable records that have email_addres
          # attributes.
          email_address_class::Email::Recipient.class_eval do
            # Returns the model that is messageable.
            def messageable_with_spec
              messageable_without_spec || messageable_spec
            end
            alias_method_chain :messageable, :spec
            
            # If messageable is a string, then sets the spec, otherwise uses
            # the original messageable setter
            def messageable_with_spec=(value)
              if value.is_a?(String)
                self.messageable_spec = value
              else
                self.messageable_without_spec = value
              end
            end
            alias_method_chain :messageable=, :spec
          end
          
          # Add associations for all emails the model has sent and received
          has_many  :received_emails,
                      :through => association_id
          has_many  :sent_emails,
                      :through => association_id
        end
      end
      
      module ClassMethods #:nodoc
      end
      
      module InstanceMethods
        # Contains all of the emails that have been sent and received
        #
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