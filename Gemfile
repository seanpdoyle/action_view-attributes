source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in attributes_and_token_lists.gemspec.
gemspec

rails_version = ENV.fetch("RAILS_VERSION", "7.0")

rails_constraint = if rails_version == "main"
  {github: "rails/rails"}
else
  "~> #{rails_version}.0"
end

gem "rails", rails_constraint
gem "sprockets-rails"
gem "net-smtp"

group :development do
  gem "sqlite3"
end

group :development, :test do
  gem "standard"
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
