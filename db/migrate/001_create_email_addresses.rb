class CreateEmailAddresses < ActiveRecord::Migration
  class State < ActiveRecord::Base; end
  class Event < ActiveRecord::Base; end
  class StateChange < ActiveRecord::Base; end
  
  class EmailAddress < ActiveRecord::Base
    class State < State; end
    class Event < Event; end
    class StateChange < StateChange; end
  end
  
  def self.up
    create_table :email_addresses do |t|
      t.column :emailable_id,       :integer,   :null => false, :unsigned => true, :references => nil
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
    
    PluginAWeek::Acts::StateMachine.migrate_up(EmailAddress)
  end
  
  def self.down
    PluginAWeek::Acts::StateMachine.migrate_down(EmailAddress)
    
    drop_table :email_addresses
  end
  
  def self.bootstrap
    [
      EmailAddress::State,
      EmailAddress::Event,
      EmailAddress,
      EmailAddress::StateChange
    ]
  end
end
