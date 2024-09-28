source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in action_view-attributes.gemspec.
gemspec

rails_version = ENV.fetch("RAILS_VERSION", "7.2")

rails_constraint = if rails_version == "main"
  {github: "rails/rails"}
else
  "~> #{rails_version}.0"
end

gem "rails", rails_constraint
gem "sprockets-rails"
gem "net-smtp"
gem "capybara"
gem "action_dispatch-testing-integration-capybara",
  github: "thoughtbot/action_dispatch-testing-integration-capybara", tag: "v0.1.0",
  require: "action_dispatch/testing/integration/capybara/minitest"

group :development do
  gem "sqlite3", (rails_version == "main") ? ">= 2.1" : "~> 1.4"
end

group :development, :test do
  gem "standard"
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
