# An email which has been sent to one or more recipients
class SenderEmail < SenderMessage
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