require 'has_messages'
require 'validates_as_email_address'
require 'has_emails/extensions/action_mailer'

# Adds a generic implementation for sending emails
module HasEmails
  module MacroMethods
    # Creates the following email associations:
    # * +emails+ - Emails that were composed and are visible to the owner.
    #   Emails may have been sent or unsent.
    # * +received_emails - Emails that have been received from others and are
    #   visible.  Emails may have been read or unread.
    # 
    # == Creating new emails
    # 
    # To create a new email, the +emails+ association should be used.  For
    # example:
    # 
    #   address = EmailAddress.find(123)
    #   email = user.emails.build
    #   email.subject = 'Hello'
    #   email.body = 'How are you?'
    #   email.to EmailAddress.find(456)
    #   email.save!
    #   email.deliver!
    def has_emails
      has_many  :emails,
                  :as => :sender,
                  :class_name => 'Email',
                  :conditions => {:hidden_at => nil},
                  :order => 'messages.created_at DESC'
      has_many  :received_emails,
                  :as => :receiver,
                  :class_name => 'MessageRecipient',
                  :include => :message,
                  :conditions => ['message_recipients.hidden_at IS NULL AND messages.state = ?', 'sent'],
                  :order => 'messages.created_at DESC'
      
      include HasEmails::InstanceMethods
    end
  end
  
  module InstanceMethods
    # Composed emails that have not yet been sent.  These consists of all
    # emails that are currently in the "unsent" state.
    def unsent_emails
      emails.with_state(:unsent)
    end
    
    # Composed emails that have already been sent.  These consist of all emails
    # that are currently in the "queued" or "sent states.
    def sent_emails
      emails.with_states(:queued, :sent)
    end
  end
end

ActiveRecord::Base.class_eval do
  extend HasEmails::MacroMethods
end
