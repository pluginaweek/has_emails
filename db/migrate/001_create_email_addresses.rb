class CreateEmailAddresses < ActiveRecord::Migration
  class EmailAddress < ActiveRecord::Base; end
  class StateChange < ActiveRecord::Base; end
  class StateDeadline < ActiveRecord::Base; end
  
  class State < ActiveRecord::Base
    set_table_name 'states'
    
    has_many :email_addresses, :class_name => EmailAddress.to_s, :dependent => :destroy
    has_many :from_changes, :class_name => StateChange.to_s, :foreign_key => 'from_state_id', :dependent => :destroy
    has_many :to_changes, :class_name => StateChange.to_s, :foreign_key => 'to_state_id', :dependent => :destroy
  end
  
  class Event < ActiveRecord::Base
    set_table_name 'events'
    
    has_many :state_changes, :class_name => StateChange.to_s, :foreign_key => 'event_id', :dependent => :destroy
    has_many :state_deadlines, :class_name => StateDeadline.to_s, :foreign_key => 'event_id', :dependent => :destroy
  end
  
  def self.up
    create_table :email_addresses do |t|
      t.column :emailable_id,       :integer,   :null => false, :unsigned => true, :references => nil
      t.column :emailable_type,     :string,    :null => false
      t.column :local_name,         :string,    :null => false, :limit => 382
      t.column :domain,             :string,    :null => false, :limit => 382
      t.column :verification_code,  :string,    :limit => 40
      t.column :code_expiry,        :datetime
      t.column :type,               :string,    :mull => false
      t.column :created_at,         :timestamp, :null => false
      t.column :updated_at,         :datetime,  :null => false
      t.column :deleted_at,         :datetime
    end
    add_index :email_addresses, [:local_name, :domain], :unique => true
    add_index :email_addresses, :verification_code, :unique => true
    
    PluginAWeek::Acts::StateMachine.migrate_up(:email_addresses)
  end
  
  def self.down
    PluginAWeek::Acts::StateMachine.migrate_down(:email_addresses)
    
    drop_table :email_addresses
  end
  
  def self.bootstrap
    {
      'email_address/states' => {:class => State, :conditions => ['owner_type = ?', 'EmailAddress']},
      'email_address/events' => {:class => Event, :conditions => ['owner_type = ?', 'EmailAddress']}
    }
  end
end
