require File.dirname(__FILE__) + '/../test_helper'

class RecipientExtensionTest < Test::Unit::TestCase
  fixtures :users, :email_addresses, :messages, :message_recipients
  
  def setup
    @email = messages(:unsent_from_bob)
  end
  
  def test_should_input_string
    @email.to << 'test@me.com'
    assert_equal ['john@john.com', 'test@me.com'], @email.to.map(&:email_address).map(&:to_s)
  end
  
  def test_should_input_receiver
    @email.to << email_addresses(:bob)
    assert_equal [email_addresses(:john), email_addresses(:bob)], @email.to_receivers
  end
  
  def test_should_input_message_recipients
    @email.to << EmailRecipient.new(:receiver => email_addresses(:bob), :kind => 'to')
    assert_equal [email_addresses(:john), email_addresses(:bob)], @email.to_receivers
  end
  
  def test_should_push_string
    @email.to.push('test@me.com')
    assert_equal ['john@john.com', 'test@me.com'], @email.to.map(&:email_address).map(&:to_s)
  end
  
  def test_should_push_receiver
    @email.to.push(email_addresses(:bob))
    assert_equal [email_addresses(:john), email_addresses(:bob)], @email.to_receivers
  end
  
  def test_should_push_message_recipients
    @email.to.push(EmailRecipient.new(:receiver => email_addresses(:bob), :kind => 'to'))
    assert_equal [email_addresses(:john), email_addresses(:bob)], @email.to_receivers
  end
  
  def test_should_concat_string
    @email.to.concat(['test@me.com'])
    assert_equal ['john@john.com', 'test@me.com'], @email.to.map(&:email_address).map(&:to_s)
  end
  
  def test_should_concat_receiver
    @email.to.concat([email_addresses(:bob)])
    assert_equal [email_addresses(:john), email_addresses(:bob)], @email.to_receivers
  end
  
  def test_should_concat_message_recipients
    @email.to.concat([EmailRecipient.new(:receiver => email_addresses(:bob), :kind => 'to')])
    assert_equal [email_addresses(:john), email_addresses(:bob)], @email.to_receivers
  end
  
  def test_should_delete_string
    @email.to.delete('john@john.com')
    assert_equal [], @email.to_receivers
  end
  
  def test_should_delete_receiver
    @email.to.delete(email_addresses(:john))
    assert_equal [], @email.to_receivers
  end
  
  def test_should_delete_message_recipients
    @email.to.delete(@email.to.first)
    assert_equal [], @email.to
  end
  
  def test_should_replace_string
    @email.to.replace(['bob@bob.com'])
    assert_equal ['bob@bob.com'], @email.to.map(&:email_address).map(&:to_s)
  end
  
  def test_should_replace_receiver
    @email.to.replace([email_addresses(:bob)])
    assert_equal [email_addresses(:bob)], @email.to_receivers
  end
  
  def test_should_replace_message_recipients
    @email.to.replace([])
    assert_equal [], @email.to_receivers
  end
  
  def test_should_set_kind_for_to_recipients
    @email.to << users(:bob)
    assert_equal 'to', @email.to.last.kind
  end
  
  def test_should_set_kind_for_cc_recipients
    @email.cc << users(:bob)
    assert_equal 'cc', @email.cc.last.kind
  end
  
  def test_should_set_kind_for_bcc_recipients
    @email.bcc << users(:bob)
    assert_equal 'bcc', @email.bcc.last.kind
  end
end
