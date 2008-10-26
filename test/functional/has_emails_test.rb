require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class EmailAddressByDefaultFunctionalTest < Test::Unit::TestCase
  def setup
    @email_address = create_email_address
  end
  
  def test_should_not_have_any_emails
    assert @email_address.emails.empty?
  end
  
  def test_should_not_have_any_unsent_emails
    assert @email_address.unsent_emails.empty?
  end
  
  def test_should_not_have_any_sent_emails
    assert @email_address.sent_emails.empty?
  end
  
  def test_should_not_have_any_received_emails
    assert @email_address.received_emails.empty?
  end
end

class EmailAddressFunctionalTest < Test::Unit::TestCase
  def setup
    @email_address = create_email_address
  end
  
  def test_should_be_able_to_create_new_emails
    email = @email_address.emails.build
    assert_instance_of Email, email
    assert_equal @email_address, email.sender
  end
  
  def test_should_be_able_to_send_new_emails
    email = @email_address.emails.build
    email.to create_email_address(:spec => 'jane.smith@gmail.com')
    assert email.deliver
  end
end

class EmailAddressWithUnsentEmails < Test::Unit::TestCase
  def setup
    @email_address = create_email_address
    @sent_email = create_email(:sender => @email_address, :to => create_email_address(:spec => 'jane.smith@gmail.com'))
    @sent_email.deliver
    @first_draft = create_email(:sender => @email_address)
    @second_draft = create_email(:sender => @email_address)
  end
  
  def test_should_have_unsent_emails
    assert_equal [@first_draft, @second_draft], @email_address.unsent_emails
  end
  
  def test_should_include_unsent_emails_in_emails
    assert_equal [@sent_email, @first_draft, @second_draft], @email_address.emails
  end
end

class EmailAddressWithSentEmails < Test::Unit::TestCase
  def setup
    @email_address = create_email_address
    @to = create_email_address(:spec => 'jane.smith@gmail.com')
    @draft = create_email(:sender => @email_address)
    
    @first_sent_email = create_email(:sender => @email_address, :to => @to)
    @first_sent_email.deliver
    
    @second_sent_email = create_email(:sender => @email_address, :to => @to)
    @second_sent_email.deliver
  end
  
  def test_should_have_sent_emails
    assert_equal [@first_sent_email, @second_sent_email], @email_address.sent_emails
  end
  
  def test_should_include_sent_emails_in_emails
    assert_equal [@draft, @first_sent_email, @second_sent_email], @email_address.emails
  end
end

class EmailAddressWithReceivedEmails < Test::Unit::TestCase
  def setup
    @sender = create_email_address
    @email_address = create_email_address(:spec => 'jane.smith@gmail.com')
    
    @unsent_email = create_email(:sender => @sender, :to => @email_address)
    
    @first_sent_email = create_email(:sender => @sender, :to => @email_address)
    @first_sent_email.deliver
    
    @second_sent_email = create_email(:sender => @sender, :to => @email_address)
    @second_sent_email.deliver
  end
  
  def test_should_have_received_emails
    assert_equal [@first_sent_email, @second_sent_email], @email_address.received_emails.map(&:message)
  end
end

class EmailAddressWithHiddenEmailsTest < Test::Unit::TestCase
  def setup
    @email_address = create_email_address
    @friend = create_email_address(:spec => 'jane.smith@gmail.com')
    
    hidden_unsent_email = create_email(:sender => @email_address)
    hidden_unsent_email.hide!
    @unsent_email = create_email(:sender => @email_address)
    
    hidden_sent_email = create_email(:sender => @email_address, :to => @friend)
    hidden_sent_email.deliver
    hidden_sent_email.hide!
    @sent_email = create_email(:sender => @email_address, :to => @friend)
    @sent_email.deliver
    
    hidden_received_email = create_email(:sender => @friend, :to => @email_address)
    hidden_received_email.deliver
    hidden_received_email.recipients.first.hide!
    @received_email = create_email(:sender => @friend, :to => @email_address)
    @received_email.deliver
  end
  
  def test_should_not_include_hidden_emails_in_emails
    assert_equal [@unsent_email, @sent_email], @email_address.emails
  end
  
  def test_should_not_include_hidden_emails_in_unsent_emails
    assert_equal [@unsent_email], @email_address.unsent_emails
  end
  
  def test_should_not_include_hidden_emails_in_sent_emails
    assert_equal [@sent_email], @email_address.sent_emails
  end
  
  def test_should_not_include_hidden_emails_in_received_emails
    assert_equal [@received_email], @email_address.received_emails.map(&:message)
  end
end
