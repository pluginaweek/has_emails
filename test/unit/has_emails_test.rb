require File.dirname(__FILE__) + '/../test_helper'

class HasEmailsTest < Test::Unit::TestCase
  fixtures :users, :email_addresses, :messages, :message_recipients, :state_changes
  
  def test_should_generate_received_association
    assert_equal [messages(:sent_from_bob), messages(:sent_from_mary)], users(:john).received_emails.map(&:email)
  end
  
  def test_should_generate_unsent_association
    assert_equal [messages(:unsent_from_bob)], users(:bob).unsent_emails
  end
  
  def test_should_generate_sent_association
    assert_equal [messages(:sent_from_bob), messages(:queued_from_bob)], users(:bob).sent_emails
  end
  
  def test_should_generate_inbox
    assert_instance_of MessageBox, users(:bob).email_box
  end
  
  def test_inbox_should_contain_received_messages
    u = users(:bob)
    assert_equal u.received_emails, u.email_box.inbox
  end
  
  def test_inbox_should_contain_unsent_messages
    u = users(:bob)
    assert_equal u.unsent_emails, u.email_box.unsent
  end
  
  def test_inbox_should_contain_sent_messages
    u = users(:bob)
    assert_equal u.sent_emails, u.email_box.sent
  end
end
