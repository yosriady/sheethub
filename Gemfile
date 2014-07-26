ruby '2.1.2'
source 'https://rubygems.org'

gem 'rails', '4.1.1'

# Server and DB
gem 'pg'
gem 'unicorn-rails'

# Frontend
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'
# gem 'gon'
# gem 'bootstrap-sass', '~> 3.1.1'
# gem 'slim-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# S3 upload
# gem 'aws-sdk'
# gem 's3_direct_upload'

# API
gem 'grape'
gem 'grape-jbuilder'

# Others
gem 'sdoc', '~> 0.4.0',          group: :doc

group :production do
  gem 'heroku-deflater'
  gem 'rails_12factor'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'spring'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'rspec'
end

group :test do
  gem 'database_cleaner'
  gem 'capybara'
  gem 'selenium-webdriver'
end