ruby '2.1.2'
source 'https://rubygems.org'

gem 'rails', '4.1.1'

# Server and DB
gem 'pg'
gem 'unicorn-rails'

# Task Queue
# gem 'sidekiq'

# User authentication
# gem 'devise'

# Tags
gem 'acts-as-taggable-on'

# Pagination
gem 'kaminari'

# Form
gem 'simple_form'
gem 'chosen-rails'

# Frontend
gem 'bootstrap-sass', '~> 3.1.1'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'autoprefixer-rails'
# gem 'gon'
# gem 'slim-rails'


# File upload
# gem 'carrierwave'
# gem 'fog'
# gem 'mini_magick'
# gem 'aws-sdk'
# gem "paperclip", "~> 4.1"
# gem 's3_direct_upload'

# API
gem 'grape'
gem 'grape-jbuilder'

# Others
gem 'bitmask_attributes'
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
  gem 'factory_girl_rails'
  gem 'faker'
end

group :test do
  gem 'database_cleaner'
  gem 'capybara'
  gem 'selenium-webdriver'
end