# Represents a valid RFC822 email address
class EmailAddress < ActiveRecord::Base
  class << self
    # Converts the specified record to an EmailAddress.  It will convert the
    # following types:
    # 1. String
    # 2. A record with an email_address attribute
    # 
    # If an EmailAddress is specified, the same model will be returned.  An
    # ArgumentError is raised if it doesn't match the above and is not already
    # an EmailAddress.
    def convert_from(record)
      if record
        if EmailAddress === record
          record
        elsif String === record
          EmailAddress.new(:spec => record)
        elsif record.respond_to?(:email_address)
          address = EmailAddress.new(:spec => record.email_address)
          address.name = record.name if record.respond_to?(:name)
          address
        else
          raise ArgumentError, "Cannot convert #{record.class} to an EmailAddress"
        end
      end
    end
    
    # Determines if the given spec is a valid address using the RFC822 spec
    def valid?(spec)
      !RFC822::EmailAddress.match(spec).nil?
    end
  end
  
  acts_as_tokenized :token_field => 'verification_code', :token_length => 32
  
  # Support e-mail address verification
  has_states    :initial => :unverified
  
  # Add messaging capabilities.  This will give us an email_box.
  has_messages  :emails,
                  :message_class => 'Email'
  belongs_to    :emailable,
                  :polymorphic => true
  
  validates_presence_of       :spec
  
  with_options(:allow_nil => true) do |klass|
    klass.validates_uniqueness_of     :spec
    klass.validates_as_email_address  :spec
  end
  
  # The name of the person who owns this email address
  attr_accessor :name
  
  # Ensure that the e-mail address has a verification code that can be sent
  # to the user
  before_create :set_code_expiry
  
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
    @name || ''
  end
  
  # Returns a string version of the email address plus any name like
  # "John Doe <john.doe@gmail.com>".  In order to have a valid name within the
  # string, you must override +name+.
  def with_name
    name.blank? ? to_s : "#{name} <#{to_s}>"
  end
  
  # Returns the full email address (without the name)
  def to_s #:nodoc
    spec
  end
  
  private
  # Sets the time at which the verification code will expire
  def set_code_expiry
    self.code_expiry = 48.hour.from_now
  end
  
  # Parses the current spec and sets +@local_name+ and +@domain+ based on the
  # matching groups within the regular expression
  def parse_spec
    if !@local_name && !@domain && match = RFC822::EmailAddress.match(spec)
      @local_name = match.captures[0]
      @domain = match.captures[1]
    end
  end
end
