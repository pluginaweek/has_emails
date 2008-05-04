require 'has_messages'
require 'validates_as_email_address'
require 'has_emails/extensions/action_mailer'

module PluginAWeek #:nodoc:
  # Adds a generic implementation for sending emails
  module HasEmails
    def self.included(base) #:nodoc:
      base.class_eval do
        extend PluginAWeek::HasEmails::MacroMethods
      end
    end
    
    module MacroMethods
      # Creates the following email associations:
      # * +emails+ - Emails that were composed and are visible to the owner.  Emails may have been sent or unsent.
      # * +received_emails - Emails that have been received from others and are visible.  Emails may have been read or unread.
      # 
      # == Creating new emails
      # 
      # To create a new email, the +emails+ association should be used, for example:
      # 
      #   address = EmailAddress.find(123)
      #   email = user.emails.build
      #   email.subject = 'Hello'
      #   email.body = 'How are you?'
      #   email.to User.EmailAddress(456)
      #   email.save!
      #   email.deliver!
      # 
      # Alternatively, 
      def has_emails
        has_many  :emails,
                    :as => :sender,
                    :class_name => 'Email',
                    :conditions => {:hidden_at => nil},
                    :order => 'messages.created_at ASC'
        has_many  :received_emails,
                    :as => :receiver,
                    :class_name => 'MessageRecipient',
                    :include => :message,
                    :conditions => ['message_recipients.hidden_at IS NULL AND messages.state = ?', 'sent'],
                    :order => 'messages.created_at ASC'
        
        include PluginAWeek::HasEmails::InstanceMethods
      end
    end
    
    module InstanceMethods
      # Composed emails that have not yet been sent
      def unsent_emails
        emails.with_state('unsent')
      end
      
      # Composed emails that have already been sent
      def sent_emails
        emails.with_states(%w(queued sent))
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include PluginAWeek::HasEmails
end
