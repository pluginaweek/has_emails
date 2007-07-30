class AddEmailRecipients < ActiveRecord::Migration
  def self.up
    change_column :message_recipients, :messageable_id, :integer, :null => true, :default => nil, :references => nil
    change_column :message_recipients, :messageable_type, :string, :null => true
    
    add_column :message_recipients, :messageable_spec, :string, :limit => 320
    add_column :message_recipients, :type, :string, :null => false, :default => 'Message'
  end

  def self.down
    remove_column :message_recipients, :type
    remove_column :message_recipients, :messageable_spec
    
    change_column :message_recipients, :messageable_id, :integer, :null => false, :references => nil
    change_column :message_recipients, :messageable_type, :string, :null => false
  end
end