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
end
