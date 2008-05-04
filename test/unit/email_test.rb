require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class EmailAfterBeingDeliveredTest < Test::Unit::TestCase
  def setup
    ActionMailer::Base.deliveries = []
    
    @email = new_email(
      :subject => 'Hello',
      :body => 'How are you?',
      :sender => create_email_address(:spec => 'webmaster@localhost'),
      :to => create_email_address(:spec => 'partners@localhost'),
      :cc => create_email_address(:spec => 'support@localhost'),
      :bcc => create_email_address(:spec => 'feedback@localhost')
    )
    assert @email.deliver!
  end
  
  def test_should_send_mail
    assert ActionMailer::Base.deliveries.any?
    
    delivery = ActionMailer::Base.deliveries.first
    assert_equal 'Hello', delivery.subject
    assert_equal 'How are you?', delivery.body
    assert_equal ['webmaster@localhost'], delivery.from
    assert_equal ['partners@localhost'], delivery.to
    assert_equal ['support@localhost'], delivery.cc
    assert_equal ['feedback@localhost'], delivery.bcc
  end
end
