class CreateDepartments < ActiveRecord::Migration
  def self.up
    create_table :departments do |t|
      t.column :name, :string, :null => false
      t.column :email_address, :string, :null => false
    end
  end

  def self.down
    drop_table :departments
  end
end