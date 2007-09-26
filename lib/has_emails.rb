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
        # * +email_addresses+ - The email addresses of this model
        # * +emails+ - A collection of Emails of which this model was the sender
        # * +email_recipients+ - A collection of EmailRecipients in which this record is a receiver
        def has_email_addresses
          has_many  :email_addresses,
                      :class_name => 'EmailAddress',
                      :as => :emailable,
                      :dependent => :destroy
          
          # Add associations for all emails the model has sent and received
          has_many  :emails,
                      :through => :email_addresses
          has_many  :email_recipients,
                      :through => :email_addresses
          
          include PluginAWeek::Has::Emails::InstanceMethods
        end
        
        # Adds support for emailing instances of this model through a single
        # email address.
        # 
        # == Generated associations
        # 
        # The following associations are created for models that support emailing:
        # * +email_address+ - The email address of this model
        # * +emails+ - A collection of Emails of which this model was the sender
        # * +email_recipients+ - A collection of EmailRecipients in which this record is a receiver
        def has_email_address
          has_one :email_address,
                    :class_name => 'EmailAddress',
                    :as => :emailable,
                    :dependent => :destroy
          
          delegate  :emails,
                    :email_recipients,
                      :to => :email_address
          
          include PluginAWeek::Has::Emails::InstanceMethods
        end
      end
      
      module InstanceMethods
        # All emails this model has received
        def received_emails
          email_recipients.active.find_in_states(:all, :unread, :read, :include => :message, :conditions => ['messages.state_id = ?', Message.states.find_by_name('sent').id]).collect do |recipient|
            ReceivedMessage.new(recipient)
          end
        end
        
        # All emails that have not yet been sent by this model (excluding any that have been deleted)
        def unsent_emails(*args)
          emails.active.unsent(*args)
        end
        
        # All emails that have been sent by this model (excluding any that have been deleted)
        def sent_emails(*args)
          emails.active.find_in_states(:all, :queued, :sent, *args)
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
