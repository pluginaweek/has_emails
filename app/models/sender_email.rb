# 
class SenderEmail < SenderMessage
  with_options(
    :class_name => 'EmailRecipient',
    :foreign_key => 'message_id',
    :order => 'position ASC',
    :dependent => true
  ) do |e|
    e.has_many  :to,
                  :conditions => ['kind = ?', 'to'],
                  :extend => [MessageRecipient::EasyBuildToExtension, EmailRecipient::EasyBuildExtension]
    e.has_many  :cc,
                  :conditions => ['kind = ?', 'cc'],
                  :extend => [MessageRecipient::EasyBuildCcExtension, EmailRecipient::EasyBuildExtension]
    e.has_many  :bcc,
                  :conditions => ['kind = ?', 'bcc'],
                  :extend => [MessageRecipient::EasyBuildBccExtension, EmailRecipient::EasyBuildExtension]
  end
end