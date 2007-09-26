# Represents an email which has been sent to one or more recipients.  This is
# essentially the same as the Message class, but overrides the +to+, +cc+, and +bcc+
# associations to that proper instances of the MessageRecipient class are created.
class Email < Message
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
    if value.is_a?(String)
      self.sender_spec = value
    else
      self.sender_without_spec = value
    end
  end
  alias_method_chain :sender=, :spec
  
  # Converts the sender into an Email Address, whether it be a string,
  # EmailAddress, or other model type
  def sender_email_address
    EmailAddress.convert_from(sender)
  end
  
  # Strings are allowed to participate in messaging
  def model_participant?
    sender_id && sender_type || sender_spec.nil?
  end
end
