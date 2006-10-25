class AddEmailRecipients < ActiveRecord::Migration
  def self.up
    add_column :message_recipients, :address_spec, :string, :limit => 384
    
    remove_index :message_recipients, :name => 'unique_message_recipients'
    add_index :message_recipients, [:message_id, :messageable_id, :type, :address_spec], :unique => true, :name => 'unique_message_recipients'
  end

  def self.down
    remove_index :message_recipients, :name => 'unique_message_recipients'
    add_index :message_recipients, [:message_id, :messageable_id, :type], :unique => true, :name => 'unique_message_recipients'
    
    remove_column :message_recipients, :address_spec
  end
end