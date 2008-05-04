require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ActionMailerTest < Test::Unit::TestCase
  class TestMailer < ActionMailer::Base
    def signed_up(recipient)
      subject    'Thanks for signing up'
      from       'MyWebApp <welcome@mywebapp.com>'
      recipients recipient
      cc         'Nobody <nobody@mywebapp.com>'
      bcc        'root@mywebapp.com'
      body       'Congratulations!'
    end
  end
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  def test_should_use_camelized_application_name_for_default_subject_prefix
    assert_equal '[AppRoot] ', ActionMailer::Base.default_subject_prefix
  end
  
  def test_should_queue_email
    assert_nothing_raised {TestMailer.queue_signed_up('john.smith@gmail.com')}
    assert_equal 1, Email.count
    
    email = Email.find(1)
    assert_equal '[AppRoot] Thanks for signing up', email.subject
    assert_equal 'Congratulations!', email.body
    assert_equal 'MyWebApp <welcome@mywebapp.com>', email.sender.with_name
    assert_equal ['john.smith@gmail.com'], email.to.map(&:with_name)
    assert_equal ['Nobody <nobody@mywebapp.com>'], email.cc.map(&:with_name)
    assert_equal ['root@mywebapp.com'], email.bcc.map(&:with_name)
  end
  
  def test_should_deliver_email
    email = create_email(
      :subject => 'Hello',
      :body => 'How are you?',
      :sender => create_email_address(:name => 'MyWebApp', :spec => 'welcome@mywebapp.com'),
      :to => create_email_address(:spec => 'john.smith@gmail.com'),
      :cc => create_email_address(:name => 'Nobody', :spec => 'nobody@mywebapp.com'),
      :bcc => create_email_address(:spec => 'root@mywebapp.com')
    )
    
    assert_nothing_raised {ActionMailer::Base.deliver_email(email)}
    assert_equal 1, ActionMailer::Base.deliveries.size
    
    delivery = ActionMailer::Base.deliveries.first
    assert_equal 'Hello', delivery.subject
    assert_equal 'How are you?', delivery.body
    assert_equal ['welcome@mywebapp.com'], delivery.from
    assert_equal ['john.smith@gmail.com'], delivery.to
    assert_equal ['nobody@mywebapp.com'], delivery.cc
    assert_equal ['root@mywebapp.com'], delivery.bcc
  end
end
