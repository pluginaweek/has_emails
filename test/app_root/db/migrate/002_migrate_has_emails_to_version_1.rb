class MigrateHasEmailsToVersion1 < ActiveRecord::Migration
  def self.up
    Rails::Plugin.find(:has_emails).migrate(1)
  end
  
  def self.down
    Rails::Plugin.find(:has_emails).migrate(0)
  end
end
