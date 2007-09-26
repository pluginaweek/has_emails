# Represents a recipient on an email
class EmailRecipient < MessageRecipient
  validates_presence_of       :receiver_spec
  validates_as_email_address  :receiver_spec,
                                :allow_nil => true
  
  before_save :ensure_exclusive_references
  
  # Alias for domain-specific language
  alias_method    :email, :message
  alias_method    :email=, :message=
  alias_attribute :email_id, :message_id
  
  delegate  :to_s,
              :to => :email_address
  
  # Returns the receiver of the message.  This can be a string if being sent
  # to an arbitrary e-mail address.
  def receiver_with_spec
    receiver_without_spec || receiver_spec
  end
  alias_method_chain :receiver, :spec
  
  # If receiver is a string, then sets the spec, otherwise uses the original
  # receiver setter
  def receiver_with_spec=(value)
    self.receiver_spec = EmailAddress.convert_from(value).spec
    self.receiver_without_spec = value if !value.is_a?(String)
  end
  alias_method_chain :receiver=, :spec
  
  # Converts the receiver into an Email Address, whether it be a string,
  # EmailAddress, or other model type
  def email_address
    EmailAddress.convert_from(receiver_spec)
  end
  
  # The name of the person whose receiving the email
  def name
    receiver_without_spec ? EmailAddress.convert_from(receiver_without_spec).name : email_address.name
  end
  
  # Returns a string version of the email address plus any name like
  # "John Doe <john.doe@gmail.com>"..
  def with_name
    address = self.email_address
    address.name = self.name
    address.with_name
  end
  
  private
  def validate_on_create #:nodoc:
    begin
      email_address if receiver
      true
    rescue ArgumentError
      errors.add 'receiver_id', 'must be a string, have a email_address attribute, or be a class that has_email_addresses'
    end
  end
  
  # Strings are allowed to participate in messaging
  def model_participant?
    receiver_id && receiver_type || receiver_spec.nil?
  end
  
  # Ensures that the country id/user region combo is not set at the same time as
  # the region id
  def ensure_exclusive_references
    if model_participant?
      self.receiver_spec = nil
    else
      self.receiver_id = nil
      self.receiver_type = nil
    end
    
    true
  end
end
