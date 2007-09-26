require File.dirname(__FILE__) + '/../test_helper'

class EmailTest < Test::Unit::TestCase
  fixtures :users, :email_addresses, :messages, :message_recipients
  
  def test_should_be_valid
    assert_valid messages(:sent_from_bob)
  end
  
  def test_to_should_create_email_recipient
    assert_instance_of EmailRecipient, messages(:sent_from_bob).to.build
  end
  
  def test_cc_should_create_email_recipient
    assert_instance_of EmailRecipient, messages(:sent_from_bob).cc.build
  end
  
  def test_bcc_should_create_email_recipient
    assert_instance_of EmailRecipient, messages(:sent_from_bob).bcc.build
  end
  
  def test_sender_should_be_spec_if_arbitrary_email_address_used
    assert_equal 'stranger@somewhere.com', messages(:unsent_from_stranger).sender
  end
  
  def test_sender_should_be_model_if_known_email_address_used
    assert_equal email_addresses(:bob), messages(:sent_from_bob).sender
  end
  
  def test_should_set_sender_spec_if_sender_is_arbitrary_email_address
    email = messages(:unsent_from_stranger)
    email.sender = 'stranger@somewhereelse.com'
    assert_equal 'stranger@somewhereelse.com', email.sender_spec
    assert_nil email.sender_id
    assert_nil email.sender_type
  end
  
  def test_should_set_sender_if_sender_is_known_email_address
    email = messages(:unsent_from_stranger)
    email.sender_spec = nil
    email.sender = email_addresses(:john)
    assert_equal 2, email.sender_id
    assert_equal 'EmailAddress', email.sender_type
    assert_nil email.sender_spec
  end
  
  def test_sender_email_address_should_convert_sender_spec_if_arbitrary_email_address_used
    email_address = messages(:unsent_from_stranger).sender_email_address
    assert_instance_of EmailAddress, email_address
    assert_equal 'stranger@somewhere.com', email_address.spec
  end
  
  def test_sender_email_address_should_use_sender_if_known_email_address_used
    email_address = messages(:sent_from_bob).sender_email_address
    assert_instance_of EmailAddress, email_address
    assert_equal 'bob@bob.com', email_address.spec
  end
  
  def test_reply_should_use_sender_spec_for_sender_if_arbitrary_email_address_used
    message = messages(:unsent_from_stranger)
    reply = message.reply
    assert_equal 'stranger@somewhere.com', reply.sender
  end
  
  def test_forward_should_use_sender_spec_for_sender_if_arbitrary_email_address_used
    message = messages(:unsent_from_stranger)
    forward = message.forward
    assert_equal 'stranger@somewhere.com', forward.sender
  end
end
