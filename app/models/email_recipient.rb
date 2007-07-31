# Represents a recipient on an email
class EmailRecipient < MessageRecipient
  validates_as_email_address  :messageable_spec,
                                :allow_nil => true
  
  before_save :ensure_exclusive_references
  
  # Alias for domain-specific language
  alias_method    :email, :message
  alias_method    :email=, :message=
  alias_attribute :email_id, :message_id
  
  delegate  :name,
            :with_name,
            :to_s,
              :to => :email_address
  
  # Returns the model that is messageable.  This can be a string if being sent
  # to an arbitrary e-mail address.
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
  
  # Converts the messageable object into an Email Address, whether it be a
  # string, EmailAddress, or other model type
  def email_address
    EmailAddress.convert_from(messageable)
  end
  
  # Actually delivers the email to therecipient
  def deliver
    ApplicationMailer.deliver_email(self)
  end
  
  private
  def validate_on_create #:nodoc:
    begin
      email_address if messageable
      true
    rescue ArgumentError
      errors.add 'messageable_id', 'must be a string, have a email_address attribute, or be a class that has_email_addresses'
    end
  end
  
  # Strings are allowed to participate in messaging
  def model_participant?
    messageable_id && messageable_type || messageable_spec.nil?
  end
  
  # Ensures that the country id/user region combo is not set at the same time as
  # the region id
  def ensure_exclusive_references
    if model_participant?
      self.messageable_spec = nil
    else
      self.messageable_id = nil
      self.messageable_type = nil
    end
    
    true
  end
end