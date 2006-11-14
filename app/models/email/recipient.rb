class Email < Message #:nodoc:
  class Recipient < Message::Recipient
    # Included for support of recipients from emails sent by a string-based
    # sender
    belongs_to                :message,
                                :class_name => 'Email',
                                :foreign_key => 'message_id'
    alias_method              :email, :message
    alias_method              :email=, :message=
    alias_attribute           :email_id, :message_id
    
    validates_as_email        :messageable_spec,
                                :allow_nil => true
    validates_xor_presence_of :messageable_id,
                              :messageable_spec
    
    alias_attribute           :messageable, :messageable_spec
    
    # Converts the messageable object into an Email Address
    def email_address
      EmailAddress.convert_from(messageable)
    end
    
    # Returns a string version of the email address
    def to_s #:nodoc
      email_address.to_s
    end
    
    private
    def validate_on_create #:nodoc:
      begin
        email_address if messageable
        true
      rescue
        errors.add 'messageable_id', 'must be a string, have a email_address attribute, or be a class that acts_as_emailable'
      end
    end
  end
end