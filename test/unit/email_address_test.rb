require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class EmailAddressByDefaultTest < Test::Unit::TestCase
  def setup
    @email_address = EmailAddress.new
  end
  
  def test_should_not_have_a_name
    assert @email_address.name.blank?
  end
  
  def test_should_not_have_a_spec
    assert @email_address.name.blank?
  end
end

class EmailAddressTest < Test::Unit::TestCase
  def test_should_be_valid_with_a_set_of_valid_attributes
    email_address = new_email_address
    assert email_address.valid?
  end
  
  def test_should_require_a_spec
    email_address = new_email_address(:spec => nil)
    assert !email_address.valid?
    assert email_address.errors.invalid?(:spec)
  end
  
  def test_should_require_a_properly_formatted_email
    email_address = new_email_address(:spec => '!@@!@@!')
    assert !email_address.valid?
    assert email_address.errors.invalid?(:spec)
  end
  
  def test_should_not_allow_emails_less_than_3_characters
    email_address = new_email_address(:spec => 'aa')
    assert !email_address.valid?
    assert email_address.errors.invalid?(:spec)
    
    email_address.spec = 'a@a'
    assert email_address.valid?
  end
  
  def test_should_not_allow_emails_longer_than_320_characters
    email_address = new_email_address(:spec => 'a' * 314 + '@a.com')
    assert email_address.valid?
    
    email_address.spec += 'a'
    assert !email_address.valid?
    assert email_address.errors.invalid?(:spec)
  end
  
  def test_should_require_a_unique_spec_scoped_by_name
    email_address = create_email_address(:spec => 'john.smith@gmail.com', :name => 'John Smith')
    
    second_email_address = new_email_address(:spec => 'john.smith@gmail.com', :name => 'John Smith II')
    assert second_email_address.valid?
    
    second_email_address = new_email_address(:spec => 'john.smith@gmail.com', :name => 'John Smith')
    assert !second_email_address.valid?
    assert second_email_address.errors.invalid?(:spec)
  end
  
  def test_should_not_require_a_name
    email_address = new_email_address(:name => nil)
    assert email_address.valid?
  end
  
  def test_should_protect_attributes_from_mass_assignment
    email_address = EmailAddress.new(
      :id => 1,
      :name => 'John Smith',
      :spec => 'john.smith@gmail.com'
    )
    
    assert_nil email_address.id
    assert_equal 'John Smith', email_address.name
    assert_equal 'john.smith@gmail.com', email_address.spec
  end
end

class EmailAddressFromAddressTest < Test::Unit::TestCase
  def setup
    @email_address = EmailAddress.new(:address => 'John Smith <john.smith@gmail.com>')
  end
  
  def test_should_be_valid
    assert @email_address.valid?
  end
  
  def test_should_find_a_name
    assert_equal 'John Smith', @email_address.name
  end
  
  def test_should_find_a_spec
    assert_equal 'john.smith@gmail.com', @email_address.spec
  end
end

class EmailAddressFromAddressWithoutNameTest < Test::Unit::TestCase
  def setup
    @email_address = EmailAddress.new(:address => 'john.smith@gmail.com')
  end
  
  def test_should_be_valid
    assert @email_address.valid?
  end
  
  def test_should_not_find_a_name
    assert @email_address.name.blank?
  end
  
  def test_should_find_a_spec
    assert_equal 'john.smith@gmail.com', @email_address.spec
  end
end

class EmailAddressAfterBeingCreatedTest < Test::Unit::TestCase
  def setup
    @email_address = create_email_address(:name => 'John Smith', :spec => 'john.smith@gmail.com')
  end
  
  def test_should_record_when_it_was_created
    assert_not_nil @email_address.created_at
  end
  
  def test_should_record_when_it_was_updated
    assert_not_nil @email_address.updated_at
  end
  
  def test_should_generate_an_address_with_the_name
    assert_equal 'John Smith <john.smith@gmail.com>', @email_address.with_name
  end
end

class EmailAddressAsAClassTest < Test::Unit::TestCase
  def test_should_be_able_to_split_address_containing_name
    name, spec = EmailAddress.split_address('John Smith <john.smith@gmail.com>')
    assert_equal 'John Smith', name
    assert_equal 'john.smith@gmail.com', spec
  end
  
  def test_should_be_able_to_split_address_not_containing_name
    name, spec = EmailAddress.split_address('john.smith@gmail.com')
    assert_nil name
    assert_equal 'john.smith@gmail.com', spec
  end
  
  def test_should_be_able_to_find_an_existing_email_by_address
    email_address = create_email_address(:address => 'John Smith <john.smith@gmail.com>')
    assert_equal email_address, EmailAddress.find_or_create_by_address('John Smith <john.smith@gmail.com>')
  end
  
  def test_should_be_able_to_create_from_a_new_address
    email_address = EmailAddress.find_or_create_by_address('John Smith <john.smith@gmail.com>')
    assert !email_address.new_record?
    assert_equal 'John Smith', email_address.name
    assert_equal 'john.smith@gmail.com', email_address.spec
  end
end
