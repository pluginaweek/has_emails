class MigrateHasMessagesToVersion2 < ActiveRecord::Migration
  def self.up
    ActiveRecord::Migrator.new(:up, "#{directory}/db/migrate", 0).migrations.each do |migration|
      migration.migrate(:up)
    end
  end
  
  def self.down
    ActiveRecord::Migrator.new(:up, "#{directory}/db/migrate", 0).migrations.each do |migration|
      migration.migrate(:down)
    end
  end
  
  private
    def self.directory
      Rails.plugins.find {|plugin| plugin.name == 'has_messages'}.directory
    end
end
