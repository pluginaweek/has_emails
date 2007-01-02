class AddEmailRecipients < ActiveRecord::Migration
  def self.up
    add_column :message_recipients, :messageable_spec, :string, :limit => 384
    
    remove_index :message_recipients, :name => 'index_message_recipients_on_message_and_messageable_and_type'
    add_index :message_recipients, [:message_id, :messageable_id, :type, :messageable_spec], :unique => true, :name => 'index_message_recipients_on_message_and_messageable_and_spec'
  end

  def self.down
    remove_index :message_recipients, :name => 'index_message_recipients_on_message_and_messageable_and_spec'
    add_index :message_recipients, [:message_id, :messageable_id, :type], :unique => true, :name => 'index_message_recipients_on_message_and_messageable_and_type'
    
    remove_column :message_recipients, :messageable_spec
  end
end