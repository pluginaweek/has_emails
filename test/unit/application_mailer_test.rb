require File.dirname(__FILE__) + '/../test_helper'

class ApplicationMailerTest < Test::Unit::TestCase
  fixtures :users, :email_addresses, :messages, :message_recipients, :state_changes
  
  class TestMailer < ApplicationMailer
    def signed_up(recipient)
      recipients recipient
      subject    'Thanks for signing up'
      from       'welcome@mywebapp.com'
      cc         'nobody@mywebapp.com'
      bcc        'root@mywebapp.com'
      body       'Congratulations!'
    end
  end
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.raise_delivery_errors = true
    ActionMailer::Base.deliveries = []
    
    @original_logger = TestMailer.logger
    @recipient = email_addresses(:bob)
  end
  
  def test_should_use_camelized_application_name_for_default_subject_prefix
    assert_equal '[AppRoot] ', ApplicationMailer.default_subject_prefix
  end
  
  def test_should_queue_email
    assert_nothing_raised { TestMailer.queue_signed_up(@recipient) }
    assert_equal 6, Email.count
    
    email = Email.find(6)
    assert_equal '[AppRoot] Thanks for signing up', email.subject
    assert_equal 'Congratulations!', email.body
    assert_equal [@recipient], email.to.map(&:receiver)
    assert_equal 'welcome@mywebapp.com', email.sender
    assert_equal ['nobody@mywebapp.com'], email.cc.map(&:receiver)
    assert_equal ['root@mywebapp.com'], email.bcc.map(&:receiver)
  end
  
  def test_should_deliver_email
    freeze_time do 
      expected = new_mail
      expected.to      = 'john@john.com'
      expected.cc      = 'mary@mary.com'
      expected.subject = 'Another funny joke'
      expected.body    = 'Where do cows go on a date? ...To the moovies!'
      expected.from    = 'bob@bob.com'
      expected.date    = Time.now
      
      assert_nothing_raised { ApplicationMailer.deliver_email(messages(:unsent_from_bob)) }
      assert_not_nil ActionMailer::Base.deliveries.first
      assert_equal expected.encoded, ActionMailer::Base.deliveries.first.encoded
    end
  end
  
  private
  def new_mail( charset="utf-8" )
    mail = TMail::Mail.new
    mail.mime_version = "1.0"
    if charset
      mail.set_content_type "text", "plain", { "charset" => charset }
    end
    mail
  end
end
