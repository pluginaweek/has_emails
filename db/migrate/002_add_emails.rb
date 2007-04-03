class AddEmails < ActiveRecord::Migration
  def self.up
    change_column :messages, :from_id,        :integer, :null => true, :default => nil, :unsigned => true, :references => nil
    change_column :messages, :from_type,      :string,  :null => true
    change_column :messages, :recipient_id,   :integer, :null => true, :default => nil, :unsigned => true, :references => nil
    change_column :messages, :recipient_type, :string,  :null => true
    
    add_column :messages, :from_spec,       :string, :limit => 384
    add_column :messages, :recipient_spec,  :string, :limit => 384
    add_column :messages, :type,            :string, :null => false
  end

  def self.down
    remove_column :messages, :type
    remove_column :messages, :recipient_spec
    remove_column :messages, :from_spec
    
    change_column :messages, :from_id,        :integer, :null => false, :unsigned => true, :references => nil
    change_column :messages, :from_type,      :string,  :null => false
    change_column :messages, :recipient_id,   :integer, :null => false, :unsigned => true, :references => nil
    change_column :messages, :recipient_type, :string,  :null => false
  end
end