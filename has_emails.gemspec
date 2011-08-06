$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'has_emails/version'

Gem::Specification.new do |s|
  s.name              = "has_emails"
  s.version           = HasEmails::VERSION
  s.authors           = ["Aaron Pfeifer"]
  s.email             = "aaron@pluginaweek.org"
  s.homepage          = "http://www.pluginaweek.org"
  s.description       = "Demonstrates a reference implementation for sending emails with logging and asynchronous support in ActiveRecord"
  s.summary           = "Email logging in ActiveRecord"
  s.require_paths     = ["lib"]
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- test/*`.split("\n")
  s.rdoc_options      = %w(--line-numbers --inline-source --title has_emails --main README.rdoc)
  s.extra_rdoc_files  = %w(README.rdoc CHANGELOG.rdoc LICENSE)
  
  s.add_dependency("has_messages", ">= 0.4.0")
  s.add_dependency("validates_as_email_address", ">= 0.0.2")
end
