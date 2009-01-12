# Represents a valid RFC822 email address.  See http://www.w3.org/Protocols/rfc822/
# for more information about the entire specification.
# 
# Email addresses are directly associated with emails and, therefore, should be
# used for building and delivering new e-mails.
# 
# == Associations
# 
# Email addresses have the following associations defined as a result of using
# the +has_emails+ macro:
# * +emails+ - Emails that were composed and are visible to the owner.  Emails
#   may have been sent or unsent.
# * +received_emails+ - Emails that have been received from others and are
#   visible.  Emails may have been read or unread.
# * +unsent_emails+ - Emails that have not yet been delivered
# * +sent_emails+ - Emails that have already been delivered
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
    
    # Splits the given address into a name and spec. For example,
    # 
    #   EmailAddress.split_address("John Smith <john.smith@gmail.com")  # => ["John Smith", "john.smith@gmail.com"]
    #   EmailAddress.split_address("john.smith@gmail.com")              # => [nil, "john.smith@gmail.com"]
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
