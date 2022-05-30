source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in action_view-attributes_and_token_lists.gemspec.
gemspec

rails_version = ENV.fetch("RAILS_VERSION", "7.0")

if rails_version == "main"
  rails_constraint = { github: "rails/rails" }
else
  rails_constraint = "~> #{rails_version}.0"
end

gem "rails", rails_constraint
gem "sprockets-rails"

group :development do
  gem 'sqlite3'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
