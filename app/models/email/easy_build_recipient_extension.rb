class Email < Message #:nodoc:
  module EasyBuildRecipientExtension #:nodoc:
    include ::Message::EasyBuildRecipientExtension
    
    # Checks if the recipient and record are equal, using the recipient's
    # email_address
    def is_recipient_equal?(recipient, record) #:nodoc:
      recipient.email_address.to_s == EmailAddress.convert_from(record).to_s
    end
    
    def raise_on_type_mismatch(record) #:nodoc:
#      unless record.is_a?(@reflection.klass) || record.is_a?(EmailAddress) || record.is_a?(String)
#        raise ActiveRecord::AssociationTypeMismatch, "#{@reflection.class_name} expected, got #{record.class}"
#      end
    end
  end
end