# Represents an email which has been sent to one or more recipients.  This is
# essentially the same as the Message class, but overrides how the it is
# delivered.
class Email < Message
  after_deliver :deliver_email
  
  private
    # Actually delivers the email to the recipients
    def deliver_email
      ActionMailer::Base.deliver_email(self)
    end
end
