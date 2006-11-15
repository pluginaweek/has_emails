# Represents a verified or unverified email address being used by a user
#
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
    def is_valid?(spec)
      !RFC822::EmailAddress.match(spec).nil?
    end
    
    # Finds an email-address with the given spec
    def find_by_spec(number, spec, *args)
      if match = RFC822::EmailAddress.match(spec)
        local_name = match.captures[0]
        domain = match.captures[1]
        
        with_scope(:find => {:conditions => ['local_name = ? AND domain = ?', local_name, domain]}) do
          find(number, *args)
        end
      end
    end
  end
  
  
  attr_protected            :local_name, :domain
  
  acts_as_state_machine     :initial => :unverified
  
  validates_presence_of     :spec
  validates_confirmation_of :spec
  validates_uniqueness_of   :local_name,
                              :scope => :domain
  validates_as_email        :spec
  
  before_create             :create_verification_code
  
  state :unverified
  state :verified
  
  # Verifies that the email address is valid
  event :verify do
    transition_to :verified, :from => :verified
  end
  
  # Sets the full address
  def spec=(value)
    @spec = value
    
    if match = RFC822::EmailAddress.match(value)
      self.local_name = match.captures[0]
      self.domain = match.captures[1]
    end
  end
  
  # Returns the full email address
  def spec
    @spec || (@spec = local_name + "@" + domain if local_name? && domain?)
  end
  
  # Returns the full email address
  def to_s #:nodoc
    spec
  end
  
  protected
  # Creates the verification code that must be used when validating the email address
  def create_verification_code
    self.verification_code = generate_token(40) do |token|
      self.class.find_by_verification_code(token).nil?
    end
    
    self.code_expiry = 48.hour.from_now
  end
end