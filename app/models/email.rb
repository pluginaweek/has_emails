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
end
