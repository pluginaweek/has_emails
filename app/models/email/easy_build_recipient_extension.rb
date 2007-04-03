class Email < Message #:nodoc:
  module EasyBuildRecipientExtension #:nodoc:
    include ::Message::EasyBuildRecipientExtension
    
    # Checks if the recipient and record are equal, using the recipient's
    # email_address
    def is_recipient_equal?(recipient, record) #:nodoc:
      recipient.email_address.to_s == EmailAddress.convert_from(record).to_s
    end
    
    def recipient_class
      EmailRecipient
    end
  end
end