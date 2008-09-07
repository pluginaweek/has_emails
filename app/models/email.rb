# Represents an email which has been sent to one or more recipients.  This is
# essentially the same as the Message class, but changes how the it is
# delivered.
class Email < Message
  state_machine :state do
    after_transition :on => 'deliver', :do => :deliver_email
  end
  
  private
    # Actually delivers the email to the recipients using ActionMailer
    def deliver_email
      ActionMailer::Base.deliver_email(self)
    end
end
