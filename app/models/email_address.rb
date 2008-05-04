# Represents a valid RFC822 email address
class EmailAddress < ActiveRecord::Base
  has_emails
  
  validates_presence_of       :spec
  validates_as_email_address  :spec
  validates_uniqueness_of     :spec,
                                :scope => 'name'
  
  class << self
    # Finds or create an email address based on the given value
    def find_or_create_by_address(address)
      name, spec = split_address(address)
      find_or_create_by_name_and_spec(name, spec)
    end
    
    # Splits the given address into a name and spec
    def split_address(address)
      if match = /^(\S.*)\s+<(.*)>$/.match(address)
        name = match[1]
        spec = match[2]
      else
        spec = address
      end
      
      return name, spec
    end
  end
  
  # Sets the value to be used for this email address.  This can come in two formats:
  # * With name - John Doe <john.doe@gmail.com>
  # * Without name - john.doe@gmail.com
  def address=(address)
    self.name, self.spec = self.class.split_address(address)
  end
  
  # Generates the value for the email address, including the name associated with
  # it (if provided).  For example,
  # 
  #   e = EmailAddress.new(:name => 'John Doe', :spec => 'john.doe@gmail.com')
  #   e.with_name # => "John Doe <john.doe@gmail.com>"
  def with_name
    name.blank? ? spec : "#{name} <#{spec}>"
  end
end
