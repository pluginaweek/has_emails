require File.dirname(__FILE__) + '/../test_helper'

class EmailAddressTest < Test::Unit::TestCase
  fixtures :departments, :users, :email_addresses, :messages, :message_recipients
  
  def test_should_convert_email_address_to_same_model
    e = email_addresses(:bob)
    assert_same e, EmailAddress.convert_from(e)
  end
  
  def test_should_convert_string_to_email_address
    e = EmailAddress.convert_from('test@email.com')
    assert_instance_of EmailAddress, e
    assert_equal 'test@email.com', e.spec
  end
  
  def test_should_convert_record_with_email_address_column_to_email_address
    department = departments(:marketing)
    e = EmailAddress.convert_from(department)
    assert_instance_of EmailAddress, e
    assert_equal department.email_address, e.spec
  end
  
  def test_should_raise_exception_if_converting_unknown_class_to_email_address
    assert_raise(ArgumentError) {EmailAddress.convert_from(1)}
  end
  
  def test_invalid_spec_should_not_be_valid
    assert !EmailAddress.valid?('invalid')
  end
  
  def test_valid_spec_should_be_valid
    assert EmailAddress.valid?('valid@valid.com')
  end
  
  def test_should_be_valid
    assert_valid email_addresses(:bob)
  end
  
  def test_should_require_spec
    assert_invalid email_addresses(:bob), :spec, nil
  end
  
  def test_should_require_unique_spec
    assert_invalid email_addresses(:bob).clone, :spec
  end
  
  def test_should_require_minimum_length_for_spec
    assert_invalid email_addresses(:bob), :spec, 'ab'
    assert_valid email_addresses(:bob), :spec, 'a@a'
  end
  
  def test_should_require_maximum_length_for_spec
    assert_invalid email_addresses(:bob), :spec, 'a' * 300 + '@' + 'a' * 20
    assert_valid email_addresses(:bob), :spec, 'a' * 300 + '@' + 'a' * 19
  end
  
  def test_should_require_specific_format_for_spec
    assert_invalid email_addresses(:bob), :spec, 'aaaaaaaaaa'
    assert_valid email_addresses(:bob), :spec, 'aaa@aaa.com'
  end
  
  def test_should_have_polymorphic_emailable_association
    assert_equal users(:bob), email_addresses(:bob).emailable
  end
  
  def test_should_have_unsent_emails_association
    assert_equal [messages(:unsent_from_bob)], email_addresses(:bob).unsent_emails
  end
  
  def test_should_have_sent_emails_association
    assert_equal [messages(:sent_from_bob), messages(:queued_from_bob)], email_addresses(:bob).sent_emails
  end
  
  def test_should_have_received_emails_association
    assert_equal [messages(:bob_to_john), messages(:mary_to_john)], email_addresses(:john).received_emails
  end
  
  def test_initial_state_should_be_unverified
    assert_equal :unverified, EmailAddress.new.state.to_sym
  end
  
  def test_should_verify_if_unverified
    e = email_addresses(:bob)
    assert e.unverified?
    assert e.verify!
    assert e.verified?
  end
  
  def test_should_not_verify_if_verified
    e = email_addresses(:john)
    assert e.verified?
    assert !e.verify!
  end
  
  def test_should_create_verification_code_on_create
    e = EmailAddress.new(:spec => 'test@me.com', :emailable => users(:bob))
    assert_nil e.verification_code
    assert e.save!
    assert_not_nil e.verification_code
    assert_equal 32, e.verification_code.length
  end
  
  def test_should_not_modify_verification_code_on_update
    e = email_addresses(:bob)
    original_verification_code = e.verification_code
    e.spec = 'test@me.com'
    assert e.save!
    assert_equal original_verification_code, e.verification_code
  end
  
  def test_should_create_code_expiry_on_create
    e = EmailAddress.new(:spec => 'test@me.com', :emailable => users(:bob))
    assert_nil e.code_expiry
    assert e.save!
    assert_not_nil e.code_expiry
  end
  
  def test_should_not_modify_code_expiry_on_update
    e = email_addresses(:bob)
    original_code_expiry = e.code_expiry
    e.spec = 'test@me.com'
    assert e.save!
    assert_equal original_code_expiry, e.code_expiry
  end
  
  def test_should_not_automatically_parse_local_name_after_find
    assert_nil email_addresses(:bob).send(:instance_variable_get, '@local_name')
  end
  
  def test_should_not_automatically_parse_domain_after_find
    assert_nil email_addresses(:bob).send(:instance_variable_get, '@domain')
  end
  
  def test_should_parse_local_name_when_accessed
    assert_equal 'bob', email_addresses(:bob).local_name
  end
  
  def test_should_parse_domain_when_accessed
    assert_equal 'bob.com', email_addresses(:bob).domain
  end
  
  def test_should_reset_local_name_and_domain_when_new_spec_is_set
    e = email_addresses(:bob)
    assert_equal 'bob', e.local_name
    assert_equal 'bob.com', e.domain
    
    e.spec = 'test@me.com'
    assert_equal 'test', e.local_name
    assert_equal 'me.com', e.domain
  end
  
  def test_name_should_be_blank
    assert_equal '', email_addresses(:bob).name
  end
  
  def test_should_return_spec_for_with_name_when_name_is_blank
    e = email_addresses(:bob)
    assert_equal e.spec, e.with_name
  end
  
  def test_should_return_name_and_spec_for_with_name_when_name_is_not_blank
    e = email_addresses(:bob)
    e.instance_eval do
      def name
        'Bob'
      end
    end
    
    assert_equal 'Bob <bob@bob.com>', e.with_name
  end
  
  def test_should_use_spec_for_stringification
    e = email_addresses(:bob)
    assert_equal e.spec, e.to_s
  end
end
