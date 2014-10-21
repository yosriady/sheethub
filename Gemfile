ruby '2.1.2'
source 'https://rubygems.org'

gem 'rails', '4.1.1'

# Server and DB
gem 'pg'
gem 'unicorn-rails'

# Task Queue
# gem 'sidekiq'

# Audio
# gem 'soundmanager-rails'

# Admin
gem 'activeadmin', github: 'activeadmin'

# Payments
gem 'paypal-express'

# Search
gem 'searchkick'
gem 'twitter-typeahead-rails'

# User authentication
gem 'omniauth'
gem 'omniauth-facebook'
gem "omniauth-google-oauth2"
gem 'devise'

# Tags
gem 'acts-as-taggable-on'

# Votes
gem 'acts_as_votable'

# Pagination
gem 'kaminari'

# Progress bar
gem 'nprogress-rails'

# Form
gem 'simple_form'
gem 'selectize-rails'

# Frontend
gem 'bootstrap-sass', '~> 3.1.1'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'autoprefixer-rails'
gem 'gon'

# File upload
gem 'aws-sdk'
gem 'paperclip'
gem 's3_direct_upload'
gem 'mini_magick', '4.0.0.rc'

# Perceptual Hash
gem 'phashion'

# API
gem 'grape'
gem 'grape-jbuilder'

# Others
gem 'friendly_id'
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
  gem 'letter_opener'
  # gem 'factory_girl_rails'
end

# Test data generationw
gem 'faker'

group :test do
  # gem 'database_cleaner'
  # gem 'capybara'
  # gem 'selenium-webdriver'
end