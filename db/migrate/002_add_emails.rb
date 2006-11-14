class AddEmails < ActiveRecord::Migration
  def self.up
    add_column :messages, :from_spec, :string, :limit => 384
    add_column :messages, :to_spec,   :string, :limit => 384
  end

  def self.down
    remove_column :messages, :to_spec
    remove_column :messages, :from_spec
  end
end