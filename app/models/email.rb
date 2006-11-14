# 
#
class Email < Message
  with_options(
    :class_name => 'Email::Recipient',
    :foreign_key => 'message_id',
    :order => 'position ASC',
    :extend => Email::EasyBuildRecipientExtension
  ) do |e|
    e.has_many    :to,  :kind => 'to'
    e.has_many    :cc,  :kind => 'cc'
    e.has_many    :bcc, :kind => 'bcc'
  end
  
  belongs_to      :reference_message,
                    :class_name => 'Email',
                    :foreign_key => 'reference_message_id'
  alias_method    :reference_email, :reference_message
  alias_method    :reference_email=, :reference_message=
  alias_attribute :reference_email_id, :reference_message_id
  
  # Support email address specs from from and recipient and
  # from_address/recipient_address.  Setting the specs is ONLY supported in the
  # Email class, not in subclasses (like User::Email).  This is because for a
  # User::Email, the from/recipient must be a user.
  alias_attribute :from, :from_spec
  alias_attribute :recipient, :recipient_spec
  
  validates_xor_presence_of :from_id,
                            :from_spec,
                            :recipient_id,
                            :recipient_spec
  
  # Support getting the recipients and addresses
  [:to, :cc, :bcc].each do |method|
    eval <<-end_eval
      def #{method}_recipients
        #{method}.collect {|recipient| recipient.messageable}
      end
      
      def #{method}_addresses
        #{method}.collect {|recipient| recipient.email_address}
      end
    end_eval
  end
  
  # Support checking the reference message if we're just a recipient
  [:from, :to, :cc, :bcc].each do |method|
    class_eval <<-end_eval
      def #{method}_with_reference_message
        recipient ? reference_message.#{method} : #{method}_without_reference_message
      end
      alias_method_chain :#{method}, :reference_message
    end_eval
  end
  
  # Returns all of the recipients in EmailAddress form
  def all_addresses
    to_addresses + cc_addresses + bcc_addresses
  end
  
  # Creates the verification code that must be used when validating the email address
  def deliver
    ApplicationMailer.deliver_email(self)
    copy_to_recipients
  end
  
  private
  # Strings are allowed to participate in messaging
  def only_model_participants?
    false
  end
end