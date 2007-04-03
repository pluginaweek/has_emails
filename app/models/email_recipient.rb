class EmailRecipient < MessageRecipient
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
  
  # Converts the messageable object into an Email Address
  def email_address
    EmailAddress.convert_from(messageable)
  end
  
  # Gets the name of the recipient.  Default is an empty string.  Override
  # this if you want it to appear in with_name
  def name
    if messageable && messageable.is_a?(EmailAddress)
      messageable.name
    else
      ''
    end
  end
  
  # Returns a string version of the email address plus any name like
  # "John Doe <john.doe@gmail.com>"
  def with_name
    name.blank? ? to_s : "#{name} <#{to_s}>"
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