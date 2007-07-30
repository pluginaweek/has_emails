class CreateEmailAddresses < ActiveRecord::Migration
  def self.up
    create_table :email_addresses do |t|
      t.column :emailable_id, :integer, :null => false, :references => nil
      t.column :emailable_type, :string, :null => false
      t.column :spec, :string, :null => false, :limit => 382
      t.column :verification_code, :string, :limit => 40
      t.column :code_expiry, :datetime
      t.column :created_at, :timestamp, :null => false
      t.column :updated_at, :datetime, :null => false
    end
    add_index :email_addresses, :spec, :unique => true
    add_index :email_addresses, :verification_code, :unique => true
    
    PluginAWeek::Has::States.migrate_up(:email_addresses)
  end
  
  def self.down
    PluginAWeek::Has::States.migrate_down(:email_addresses)
    
    drop_table :email_addresses
  end
end
