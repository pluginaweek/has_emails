require File.dirname(__FILE__) + '/../test_helper'

class EmailRecipientTest < Test::Unit::TestCase
  fixtures :users, :email_addresses, :messages, :message_recipients
  
  def test_recipient_with_email_address_should_be_valid
    assert_valid message_recipients(:bob_to_john)
  end
  
  def test_recipient_with_receiver_spec_should_be_valid
    assert_valid message_recipients(:bob_to_random)
  end
  
  def test_recipient_with_email_address_attribute_should_be_valid
    assert_valid message_recipients(:bob_to_marketing)
  end
  
  def test_should_require_minimum_length_for_receiver_spec
    assert_invalid message_recipients(:bob_to_random), :receiver_spec, 'ab'
    assert_valid message_recipients(:bob_to_random), :receiver_spec, 'a@a'
  end
  
  def test_should_require_maximum_length_for_receiver_spec
    assert_invalid message_recipients(:bob_to_random), :receiver_spec, 'a' * 300 + '@' + 'a' * 20
    assert_valid message_recipients(:bob_to_random), :receiver_spec, 'a' * 300 + '@' + 'a' * 19
  end
  
  def test_should_require_specific_format_for_receiver_spec
    assert_invalid message_recipients(:bob_to_random), :receiver_spec, 'aaaaaaaaaa'
    assert_valid message_recipients(:bob_to_random), :receiver_spec, 'aaa@aaa.com'
  end
  
  def test_email_getter_should_be_same_as_message_getter
    r = message_recipients(:bob_to_john)
    assert_equal r.email, r.message
  end
  
  def test_email_setter_should_be_same_as_message_setter
    r = message_recipients(:bob_to_john)
    r.email = messages(:sent_from_mary)
    assert_equal r.email, r.message
  end
  
  def test_email_id_getter_should_be_same_as_message_id_getter
    r = message_recipients(:bob_to_john)
    assert_equal r.email_id, r.message_id
  end
  
  def test_email_id_setter_should_be_same_as_message_id_setter
    r = message_recipients(:bob_to_john)
    r.email_id = messages(:sent_from_mary).id
    assert_equal r.email_id, r.message_id
  end
  
  def test_receiver_should_be_receiver_spec_if_string_recipient
    assert_equal 'random@random.com', message_recipients(:bob_to_random).receiver
  end
  
  def test_receiver_should_be_model_if_not_string_recipient
    assert_equal email_addresses(:john), message_recipients(:bob_to_john).receiver
  end
  
  def test_should_set_receiver_spec_if_receiver_is_string
    r = EmailRecipient.new
    r.receiver = 'test@me.com'
    assert_equal 'test@me.com', r.receiver_spec
  end
  
  def test_should_set_receiver_if_receiver_is_not_string
    r = EmailRecipient.new
    r.receiver = email_addresses(:john)
    assert_nil r.receiver_spec
    assert_equal email_addresses(:john), r.receiver
  end
end
