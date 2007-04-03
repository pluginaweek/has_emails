class AddEmailRecipients < ActiveRecord::Migration
  def self.up
    change_column :message_recipients, :messageable_id,   :integer, :null => true, :default => nil, :unsigned => true, :references => nil
    change_column :message_recipients, :messageable_type, :string,  :null => true
    
    add_column :message_recipients, :messageable_spec,  :string, :limit => 384
    add_column :message_recipients, :type,              :string, :null => false
    
    remove_index :message_recipients, :name => 'index_message_recipients_on_message_id_and_messageable'
    add_index :message_recipients, [:message_id, :messageable_id, :messageable_type, :messageable_spec], :unique => true, :name => 'index_message_recipients_on_message_id_and_messageable_and_spec'
  end

  def self.down
    remove_index :message_recipients, :name => 'index_message_recipients_on_message_id_and_messageable_and_spec'
    add_index :message_recipients, [:message_id, :messageable_id, :messageable_type], :unique => true, :name => 'index_message_recipients_on_message_id_and_messageable'
    
    remove_column :message_recipients, :type
    remove_column :message_recipients, :messageable_spec
    
    change_column :message_recipients, :messageable_id,   :integer, :null => false, :references => nil
    change_column :message_recipients, :messageable_type, :string,  :null => false
  end
end