# Load local repository plugin paths
$:.unshift("#{File.dirname(__FILE__)}/../../../associations/class_associations/lib")
$:.unshift("#{File.dirname(__FILE__)}/../../../has/has_messages/lib")
$:.unshift("#{File.dirname(__FILE__)}/../../../has/has_states/lib")
$:.unshift("#{File.dirname(__FILE__)}/../../../miscellaneous/custom_callbacks/lib")
$:.unshift("#{File.dirname(__FILE__)}/../../../miscellaneous/dry_transaction_rollbacks/lib")
$:.unshift("#{File.dirname(__FILE__)}/../../../validations/validates_as_email_address/lib")
$:.unshift("#{File.dirname(__FILE__)}/../../../../ruby/object/eval_call/lib")
$:.unshift("#{File.dirname(__FILE__)}/../../../../third_party/acts_as_tokenized/lib")
$:.unshift("#{File.dirname(__FILE__)}/../../../../third_party/nested_has_many_through/lib")

# Load the plugin testing framework
$:.unshift("#{File.dirname(__FILE__)}/../../../../test/plugin_test_helper/lib")
require 'rubygems'
require 'plugin_test_helper'

# Run the plugin migrations
%w(has_states has_messages has_emails).each do |plugin|
  Rails.plugins[plugin].migrate
end

# Run the test app migrations
ActiveRecord::Migrator.migrate("#{RAILS_ROOT}/db/migrate")

# Bootstrap the database
%w(has_messages has_emails).each do |plugin|
  plugin = Rails.plugins[plugin]
  bootstrap_path = "#{plugin.migration_path}/../bootstrap"
  
  Dir.glob("#{bootstrap_path}/*.{yml,csv}").each do |fixture_file|
    table_name = File.basename(fixture_file, '.*')
    Fixtures.new(ActiveRecord::Base.connection, table_name, nil, File.join(bootstrap_path, table_name)).insert_fixtures
  end
end

class Test::Unit::TestCase #:nodoc:
  def self.require_fixture_classes(table_names=nil)
    # Don't allow fixture classes to be required because classes like Message are
    # going to throw an error since the states and events have not yet been
    # loaded
  end
end
