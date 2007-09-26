class AddEmailRecipientSpecs < ActiveRecord::Migration
  def self.up
    # Workaround change_column not allowing change to :null => true
    remove_column :message_recipients, :receiver_id
    remove_column :message_recipients, :receiver_type
    
    add_column :message_recipients, :receiver_id, :integer, :null => true, :default => nil, :references => nil
    add_column :message_recipients, :receiver_type, :string, :null => true, :default => nil
    add_column :message_recipients, :receiver_spec, :string, :limit => 320
  end

  def self.down
    remove_column :message_recipients, :receiver_spec
    
    change_column :message_recipients, :receiver_id, :integer, :null => false, :references => nil
    change_column :message_recipients, :receiver_type, :string, :null => false
  end
end
