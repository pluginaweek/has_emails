# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{has_emails}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Pfeifer"]
  s.date = %q{2010-03-07}
  s.description = %q{Demonstrates a reference implementation for sending emails with logging and asynchronous support in ActiveRecord}
  s.email = %q{aaron@pluginaweek.org}
  s.files = ["app/models", "app/models/email_address.rb", "app/models/email.rb", "generators/has_emails", "generators/has_emails/USAGE", "generators/has_emails/has_emails_generator.rb", "generators/has_emails/templates", "generators/has_emails/templates/001_create_email_addresses.rb", "lib/has_emails.rb", "lib/has_emails", "lib/has_emails/extensions", "lib/has_emails/extensions/action_mailer.rb", "test/unit", "test/unit/email_address_test.rb", "test/unit/email_test.rb", "test/unit/action_mailer_test.rb", "test/app_root", "test/app_root/vendor", "test/app_root/vendor/plugins", "test/app_root/vendor/plugins/plugin_tracker", "test/app_root/vendor/plugins/plugin_tracker/init.rb", "test/app_root/db", "test/app_root/db/migrate", "test/app_root/db/migrate/001_migrate_has_messages_to_version_2.rb", "test/app_root/db/migrate/002_migrate_has_emails_to_version_1.rb", "test/app_root/config", "test/app_root/config/environment.rb", "test/test_helper.rb", "test/factory.rb", "test/functional", "test/functional/has_emails_test.rb", "CHANGELOG.rdoc", "init.rb", "LICENSE", "Rakefile", "README.rdoc"]
  s.homepage = %q{http://www.pluginaweek.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pluginaweek}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Demonstrates a reference implementation for sending emails with logging and asynchronous support in ActiveRecord}
  s.test_files = ["test/unit/email_address_test.rb", "test/unit/email_test.rb", "test/unit/action_mailer_test.rb", "test/functional/has_emails_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<has_messages>, [">= 0.4.0"])
      s.add_runtime_dependency(%q<validates_as_email_address>, [">= 0.0.2"])
    else
      s.add_dependency(%q<has_messages>, [">= 0.4.0"])
      s.add_dependency(%q<validates_as_email_address>, [">= 0.0.2"])
    end
  else
    s.add_dependency(%q<has_messages>, [">= 0.4.0"])
    s.add_dependency(%q<validates_as_email_address>, [">= 0.0.2"])
  end
end
