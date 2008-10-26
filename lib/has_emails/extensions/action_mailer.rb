module PluginAWeek #:nodoc:
  module HasEmails
    module Extensions #:nodoc:
      # Adds support for queueing emails so that they can be procssed in the
      # background.  Emails are stored in the database using the Email ActiveRecord
      # model.
      # 
      # == Queueing mail
      # 
      # Once a mailer action and template are defined, you can queue your message
      # for background processing like so:
      # 
      #   Notifier.queue_signup_notification(john_smith) # Queues the email
      # 
      # If you were to deliver the mail immediately, the normal process would be
      # used like so:
      # 
      #   Notifier.deliver_signup_notification(john_smith) # Delivers the email
      module ActionMailer
        def self.included(base) #:nodoc:
          base.class_eval do
            @@default_subject_prefix = "[#{File.basename(File.expand_path(Rails.root)).camelize}] "
            cattr_accessor :default_subject_prefix
            
            # Specify the prefix to use for the subject. This defaults to the
            # +default_subject_prefix+ specified for ActionMailer::Base.
            adv_attr_accessor :subject_prefix
            
            include PluginAWeek::HasEmails::Extensions::ActionMailer::InstanceMethods
            extend PluginAWeek::HasEmails::Extensions::ActionMailer::ClassMethods
          end
        end
        
        module ClassMethods
          def self.extended(base) #:nodoc:
            class << base
              alias_method_chain :method_missing, :has_emails
            end
          end
          
          # Handles calls to queue_*
          def method_missing_with_has_emails(method_symbol, *parameters)
            case method_symbol.id2name
              when /^queue_([_a-z]\w*)/
                # Queues the mail so that it's processed in the background
                new($1, *parameters).queue
              else
                # Handle the mail delivery as normal
                method_missing_without_has_emails(method_symbol, *parameters)
            end
          end
        end
        
        module InstanceMethods
          def self.included(base) #:nodoc:
            base.class_eval do
              alias_method_chain :initialize_defaults, :subject_prefix
              alias_method_chain :subject, :prefix
              alias_method :subject=, :subject_with_prefix
            end
          end
          
          # Sets or gets the subject of the email.  All subjects are prefixed with a
          # value indicating the application it is coming from.
          def subject_with_prefix(*parameters)
            if parameters.empty?
              subject_without_prefix
            else
              subject_without_prefix(subject_prefix + subject_without_prefix(*parameters))
            end
          end
          
          # Sets the default subject prefix
          def initialize_defaults_with_subject_prefix(method_name) #:nodoc
            initialize_defaults_without_subject_prefix(method_name)
            @subject_prefix ||= ::ActionMailer::Base.default_subject_prefix.dup
          end
          
          # Delivers an email based on the content in the specified email
          def email(email)
            @from       = email.sender.with_name
            @recipients = email.to.map(&:with_name)
            @cc         = email.cc.map(&:with_name)
            @bcc        = email.bcc.map(&:with_name)
            @subject    = email.subject || ''
            @body       = email.body || ''
            @sent_on    = email.updated_at
          end
          
          # Queues the current e-mail that has been constructed
          def queue
            Email.transaction do
              # Create the main email
              email = EmailAddress.find_or_create_by_address(from).emails.build(
                :subject => subject,
                :body => body,
                :to => email_addresses_for(:recipients),
                :cc => email_addresses_for(:cc),
                :bcc => email_addresses_for(:bcc)
              )
              email.queue!
            end
          end
          
          private
            # Finds or creates all of the email addresses for the given type of
            # recipient (can be :recipients, :cc, or :bcc)
            def email_addresses_for(kind)
              [send(kind)].flatten.collect {|address| EmailAddress.find_or_create_by_address(address)}
            end
        end
      end
    end
  end
end

ActionMailer::Base.class_eval do
  include PluginAWeek::HasEmails::Extensions::ActionMailer
end
