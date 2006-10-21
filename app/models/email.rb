# 
#
class Email < Message
  module EasyBuildRecipientExtension #:nodoc:
    include ::Message::EasyBuildRecipientExtension
    
    def is_recipient_equal?(recipient, record) #:nodoc:
      if record.is_a?(String)
        recipient.messageable.spec == record
      else
        recipient.messageable == record
      end
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
          raise ArgumentError, "Recipients must be instances of a class that acts_as_messageable: #{record.class}"
        end
      end
    end
  end
  
  class Recipient < Message::Recipient
    validates_as_email        :address_spec
    validates_xor_presence_of :messageable_id, :address_spec
    
    #
    #
    #
    def messageable_with_spec
      messageable = messageable_without_spec
      
      if messageable
        if messageable.is_a?(EmailAddress)
          messageable
        elsif messageable.respond_to?(:email_address)
          EmailAddress.new(:spec => messageable.email_address)
        end
      elsif address_spec?
        EmailAddress.new(:spec => address_spec)
      end
    end
    
    def messageable_with_spec=(value)
      if value.is_a?(String)
        self.address_spec = value
      else
        self.messageable_without_spec = value
      end
    end
    
    def validate_on_create #:nodoc:
      errors.add 'No email addresses could be found' if address_spec.nil? && messageable.nil?
    end
    
    #
    #
    def to_s #:nodoc
      messageable.to_s
    end
  end
  
  # Creates the verification code that must be used when validating the email address
  #
  def deliver
    ApplicationMailer.deliver_email(self)
  end
end