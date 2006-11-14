# Provides base operations for emailing
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
  def subject(*parameters)
    if parameters.empty?
      super
    else
      super("#{subject_prefix}" + super)
    end
  end
  alias_method :subject=, :subject
  
  # Delivers an email based on the content in the specified email
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
  def queue
    klass = email_class
    klass.transaction do
      # Create the main email
      email = klass.create(
        :from => from,
        :subject => subject,
        :body => body
      )
      
      # Add recipients
      email.to = to
      email.cc = cc
      email.bcc = bcc
      
      email.queue!
    end
  end
  
  private
  def initialize_defaults(method_name) #:nodoc
    @sent_on ||= Time.now
    @subject_prefix ||= @@default_subject_prefix.dup
    @recipients ||= []
    @cc ||= []
    @bcc ||= []
    
    super
  end
  
  def quote_address_if_necessary_with_conversion(address, charset) #:nodoc
    # Uses is_a? instead of === because of AssociationProxy
    if !address.is_a?(Array)
      if !(String === address || EmailAddress === address || Email::Recipient === address)
        address = EmailAddress.convert_from(address)
      end
      
      address = address.to_s
    end
    
    quote_address_if_necessary_without_conversion(address, charset)
  end
  alias_method_chain :quote_address_if_necessary, :conversion
  
  # The email class that is used when queueing emails.  If you are using strings
  # along with models that do not allow cross-model messaging, you will want to
  # override this method to determine what class should be for strings.
  def email_class
    if from.is_a?(String)
      klass = Email
    else
      klass = from.class::Email
    end
  end
end