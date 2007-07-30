class EmailRecipient < MessageRecipient
  validates_as_email_address  :messageable_spec,
                                :allow_nil => true
  validates_presence_of       :messageable_id,
                                :if => :messageable_id_required?
  
  before_save :ensure_exclusive_references
  
  # Included for support of recipients from emails sent by a string-based
  # sender
  alias_method    :email, :message
  alias_method    :email=, :message=
  alias_attribute :email_id, :message_id
  
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
  
  # Actually delivers the email
  def deliver
    ApplicationMailer.deliver_email(self)
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
  
  # Strings are allowed to participate in messaging
  def only_model_participants?
    false
  end
  
  # Does the messageable_id column need to be specified?
  def messageable_id_required?
    messageable_spec.nil?
  end
  
  # Ensures that the country id/user region combo is not set at the same time as
  # the region id
  def ensure_exclusive_references
    if messageable_id_required?
      self.messageable_spec = nil
    end
    
    true
  end
end