class HasEmailsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template '001_create_email_addresses.rb', 'db/migrate', :migration_file_name => 'create_email_addresses'
    end
  end
end
