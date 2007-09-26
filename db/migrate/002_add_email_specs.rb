class AddEmailSpecs < ActiveRecord::Migration
  def self.up
    # Workaround change_column not allowing change to :null => true
    remove_column :messages, :sender_id
    remove_column :messages, :sender_type
    
    add_column :messages, :sender_id, :integer, :null => true, :default => nil, :references => nil
    add_column :messages, :sender_type, :string, :null => true, :default => nil
    add_column :messages, :sender_spec, :string, :limit => 320
  end

  def self.down
    remove_column :messages, :sender_spec
    
    change_column :messages, :sender_id, :integer, :null => false, :references => nil
    change_column :messages, :sender_type, :string, :null => false
  end
end
