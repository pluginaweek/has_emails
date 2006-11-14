class Email < Message #:nodoc:
  module EasyBuildRecipientExtension #:nodoc:
    include ::Message::EasyBuildRecipientExtension
    
    # Checks if the recipient and record are equal, using the recipient's
    # email_address
    def is_recipient_equal?(recipient, record) #:nodoc:
      recipient.email_address.to_s == EmailAddress.convert_from(record).to_s
    end
    
    def get_recipient_class(record) #:nodoc:
      if !(Message::Recipient === record)
         message_class_name = @owner.class.name.demodulize
        begin
          if record.is_a?(String)
            @owner.class::Recipient
          else
            recipient = "#{record.class}::#{message_class_name}::Recipient".constantize
          end
        rescue NameError
          raise ArgumentError, "#{record.class} must be a class that acts_as_messageable"
        end
      end
    end
  end
end