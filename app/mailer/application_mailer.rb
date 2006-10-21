# Provides base operations for emailing
#
class ApplicationMailer < ActionMailer::Base
  @@default_subject_prefix = "[#{File.basename(File.expand_path(RAILS_ROOT)).camelize}] "
  cattr_accessor :default_subject_prefix
  
  # Specify the prefix to use for the subject. This defaults to the
  # +default_subject_prefix+ specified for ApplicationMailer.
  adv_attr_accessor :subject_prefix
  
  class << self
    def method_missing(method_symbol, *parameters) #:nodoc:
      case method_symbol.id2name
        when /^queue_([_a-z]\w*)/ then new($1, *parameters).queue
        else super
      end
    end
  end
  
  alias_method :to, :recipients
  
  # Sets or gets the subject of the email.  All subjects are prefixed with a
  # value indicating the application it is coming from.
  #
  def subject(*parameters)
    if parameters.empty?
      super
    else
      super("#{subject_prefix}" + super)
    end
  end
  alias_method :subject=, :subject
  
  # Delivers an email based on the content in the specified email
  #
  def email(email)
    from    email.from
    to      email.to
    cc      email.cc
    bcc     email.bcc
    subject email.subject
    body    email.body
    sent_on Time.now
  end
  
  # Queues the current e-mail that has been constructed
  #
  def queue
    @email = Email.create(
      :to => to,
      :cc => cc,
      :bcc => bcc,
      :subject => subject,
      :body => body
    )
  end
  
  private
  def initialize_defaults(method_name) #:nodoc
    sent_on Time.now
    @subject_prefix ||= @@subject_prefix.dup
    super
  end
  
  def quote_address_if_necessary_with_conversion(address, charset) #:nodoc
    if address.is_a?(String)
      address = quote_address_if_necessary_without_email_address(address, charset)
    else
      if Email::Recipient === address
        address = address.messageable
      elsif EmailAddress === address
        address = address.to_s
      elsif address.respond_to?(:email_address)
        address = address.email_address
      end
      
      quote_address_if_necessary(address, charset)
    end
  end
  alias_method_chain :quote_address_if_necessary, :conversion
end