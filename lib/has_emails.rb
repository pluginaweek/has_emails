require 'has_messages'
require 'validates_as_email_address'
require 'acts_as_tokenized'
require 'nested_has_many_through'

module PluginAWeek #:nodoc:
  module Has #:nodoc:
    module Emails
      def self.included(base) #:nodoc:
        base.extend(MacroMethods)
      end
      
      module MacroMethods
        # 
        def has_email_addresses
          # 
          has_many  :email_addresses,
                      :as => :emailable,
                      :extend => EmailAddress::StateExtension
          
          # Add associations for all emails the model has sent and received
          has_many  :received_emails,
                      :through => :email_addresses
          has_many  :unsent_emails,
                      :through => :email_addresses
          has_many  :sent_emails,
                      :through => :email_addresses
          
          include PluginAWeek::Has::Emails::InstanceMethods
        end
        
        # 
        def has_email_address
          has_one :email_address,
                    :as => :emailable
          
          has_email_addresses
        end
      end
      
      module InstanceMethods
        # Contains all of the emails that have been sent and received
        def email_box
          @email_box ||= MessageBox.new(received_emails, unsent_emails, sent_emails)
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include PluginAWeek::Has::Emails
end