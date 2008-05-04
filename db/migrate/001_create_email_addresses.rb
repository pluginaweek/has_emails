class CreateEmailAddresses < ActiveRecord::Migration
  def self.up
    create_table :email_addresses do |t|
      t.string :spec, :null => false, :limit => 382
      t.string :name
      t.timestamps
    end
    add_index :email_addresses, [:spec, :name], :unique => true
  end
  
  def self.down
    drop_table :email_addresses
  end
end
