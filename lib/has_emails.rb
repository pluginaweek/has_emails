require 'has_messages'
require 'validates_as_email_address'
require 'acts_as_tokenized'
require 'nested_has_many_through'

module PluginAWeek #:nodoc:
  module Has #:nodoc:
    # Adds support for sending emails to models
    module Emails
      def self.included(base) #:nodoc:
        base.extend(MacroMethods)
      end
      
      module MacroMethods
        # Adds support for emailing instances of this model through multiple
        # email addresses.
        # 
        # == Generated associations
        # 
        # The following +has_many+ associations are created for models that support
        # emailing:
        # * +email_recipients+ - A collection of EmailRecipients in which this record is a receiver
        # * +unsent_emails+ - A collection of Emails which have not yet been sent
        # * +sent_emails+ - A collection of Emails which have already been sent
        def has_email_addresses
          create_email_address_associations(:many, :email_addresses)
        end
        
        # Adds support for emailing instances of this model through a single
        # email address.
        # 
        # == Generated associations
        # 
        # The following +has_many+ associations are created for models that support
        # emailing:
        # * +email_recipients+ - A collection of EmailRecipients in which this record is a receiver
        # * +unsent_emails+ - A collection of Emails which have not yet been sent
        # * +sent_emails+ - A collection of Emails which have already been sent
        def has_email_address
          create_email_address_associations(:one, :email_address)
        end
        
        private
        def create_email_address_associations(cardinality, association_id)
          options = {
            :class_name => 'EmailAddress',
            :as => :emailable,
            :dependent => :destroy
          }
          
          send("has_#{cardinality}", association_id, options)
          
          # Add associations for all emails the model has sent and received
          has_many  :email_recipients,
                      :through => :email_addresses
          has_many  :unsent_emails,
                      :through => :email_addresses
          has_many  :sent_emails,
                      :through => :email_addresses
          
          include PluginAWeek::Has::Emails::InstanceMethods
        end
      end
      
      module InstanceMethods
        # All emails this model has received
        def received_emails
          email_recipients.find_in_states(:all, :unread, :read).collect do |recipient|
            ReceivedMessage.new(recipient)
          end
        end
        
        # Contains all of the emails that have been sent and received
        def email_box
          @email_box ||= MessageBox.new(received_emails, unsent_emails, sent_emails)
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include PluginAWeek::Has::Emails
end
