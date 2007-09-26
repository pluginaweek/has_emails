# Represents an email which has been sent to one or more recipients.  This is
# essentially the same as the Message class, but overrides the +to+, +cc+, and +bcc+
# associations to that proper instances of the MessageRecipient class are created.
class Email < Message
  validates_presence_of       :sender_spec
  validates_as_email_address  :sender_spec,
                                :allow_nil => true
  
  with_options(
    :class_name => 'EmailRecipient',
    :foreign_key => 'message_id',
    :order => 'position ASC',
    :dependent => true
  ) do |e|
    e.has_many  :to,
                  :conditions => ['kind = ?', 'to'],
                  :extend => [MessageRecipientToBuildExtension, EmailRecipientBuildExtension]
    e.has_many  :cc,
                  :conditions => ['kind = ?', 'cc'],
                  :extend => [MessageRecipientCcBuildExtension, EmailRecipientBuildExtension]
    e.has_many  :bcc,
                  :conditions => ['kind = ?', 'bcc'],
                  :extend => [MessageRecipientBccBuildExtension, EmailRecipientBuildExtension]
  end
  
  # Returns the sender of the message.  This can be a string if being sent
  # from an arbitrary e-mail address.
  def sender_with_spec
    sender_without_spec || sender_spec
  end
  alias_method_chain :sender, :spec
  
  # If sender is a string, then sets the spec, otherwise uses the original
  # sender setter
  def sender_with_spec=(value)
    self.sender_spec = EmailAddress.convert_from(value).spec
    self.sender_without_spec = value if !value.is_a?(String)
  end
  alias_method_chain :sender=, :spec
  
  # Converts the sender into an Email Address, whether it be a string,
  # EmailAddress, or other model type
  def sender_email_address
    EmailAddress.convert_from(sender_spec)
  end
  
  # The name of the person whose sending the email
  def sender_name
    sender_without_spec ? EmailAddress.convert_from(sender_without_spec).name : sender_email_address.name
  end
  
  # Returns a string version of the email address plus any name like
  # "John Doe <john.doe@gmail.com>"..
  def sender_with_name
    address = self.email_address
    address.name = self.name
    address.with_name
  end
  
  # Actually delivers the email to the recipients
  def deliver
    ApplicationMailer.deliver_email(self)
  end
  
  # Saves the +sender_spec+ in the forwarded message
  def forward
    message = super
    message.sender_spec = sender_spec
    message
  end
  
  # Saves the +sender_spec+ in the replied message
  def reply
    message = super
    message.sender_spec = sender_spec
    message
  end
  
  private
  # Strings are allowed to participate in messaging
  def model_participant?
    sender_id && sender_type || sender_spec.nil?
  end
end
