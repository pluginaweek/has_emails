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
            :foreign_key_name => :emailable
          }
          options, email_address_class, association_id = create_acts_association(:email_address, create_options, {}, *args, &extension)
          
          message_options = {:class_name => 'Email'}
          message_options[:cross_model_emailing] = options[:cross_model_emailing] if options[:cross_model_emailing]
          email_address_class.class_eval do
            acts_as_messageable message_options
          end
          
          email_address_class::Email::Recipient.class_eval do
            alias_method_chain :messageable, :spec
            alias_method_chain :messageable=, :spec
          end
          
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