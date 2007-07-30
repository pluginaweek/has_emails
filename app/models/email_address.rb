# Represents a valid RFC822 email address
class EmailAddress < ActiveRecord::Base
  include TokenGenerator
  
  class << self
    # Converts the specified record to an EmailAddress.  It will convert the
    # following types:
    # 1. String
    # 2. A record with an email_address attribute
    # 
    # An ArgumentError is raised if it doesn't match the above and is not
    # already an EmailAddress
    def convert_from(record)
      if record
        if EmailAddress === record
          record
        elsif String === record
          EmailAddress.new(:spec => record)
        elsif record.respond_to?(:email_address)
          EmailAddress.new(:spec => record.email_address)
        else
          raise ArgumentError, "Cannot convert #{record.class} to an EmailAddress"
        end
      end
    end
    
    # Determines if the email spec is a valid address using the RFC822 spec
    def valid?(spec)
      !RFC822::EmailAddress.match(spec).nil?
    end
  end
  
  # Support e-mail address verification
  has_states    :initial => :unverified
  
  # Add messaging capabilities.  This will give us an email_box.
  has_messages  :emails,
                  :message_class => 'Email'
  belongs_to    :emailable,
                  :polymorphic => true
  
  validates_presence_of       :spec
  validates_uniqueness_of     :spec
  validates_as_email_address  :spec
  
  # Ensure that the e-mail address has a verification code that can be sent
  # to the user
  before_create :create_verification_code
  
  state :unverified, :verified
  
  # Verifies that the email address is valid
  event :verify do
    transition_to :verified, :from => :unverified
  end
  
  # Sets the full address
  def spec=(new_spec)
    @local_name = @domain = nil
    write_attribute(:spec, new_spec)
  end
  
  # The part of the e-mail address before the @
  def local_name
    parse_spec if !@local_name
    @local_name
  end
  
  # The part of the e-mail address after the @
  def domain
    parse_spec if !@domain
    @domain
  end
  
  # Gets the name of the person whose email address this is.  Default is an
  # empty string.  Override this if you want it to appear in with_name
  def name
    ''
  end
  
  # Returns a string version of the email address plus any name like
  # "John Doe <john.doe@gmail.com>"
  def with_name
    name.blank? ? to_s : "#{name} <#{to_s}>"
  end
  
  # Returns the full email address
  def to_s #:nodoc
    spec
  end
  
  private
  # Creates the verification code that must be used when validating the email address
  def create_verification_code
    self.verification_code = generate_token(32) do |token|
      self.class.find_by_verification_code(token).nil?
    end
    
    self.code_expiry = 48.hour.from_now
  end
  
  def parse_spec
    if !@local_name && !@domain && match = RFC822::EmailAddress.match(spec)
      @local_name = match.captures[0]
      @domain = match.captures[1]
    end
  end
end