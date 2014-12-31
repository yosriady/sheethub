ruby '2.1.2'
source 'https://rubygems.org'

gem 'rails', '4.2.0.rc3'

# DB
gem 'pg'

# Application Server
gem 'passenger'

# Background processing
gem 'sidekiq'

# Memcached
gem 'dalli'

# Contact Form
gem 'mail_form'

# HTML Emails
gem 'roadie-rails'

# Event Analytics
gem 'mixpanel-ruby'

# Application Monitoring
gem 'newrelic_rpm'

# HTML Embed Links
gem 'auto_html'

# CSS Animations
gem 'animate-rails'

# SEO Meta Tags
gem 'metamagic'

# Payments
gem 'paypal-express'
gem 'paypal-sdk-adaptivepayments'

# Charts
gem 'groupdate'
gem 'chartkick'

# Model Validations
gem 'validates_email_format_of'

# Soft Deletion
gem "paranoia", :github => "radar/paranoia", :branch => "rails4"

# Search
gem 'searchkick'
gem 'typhoeus'
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
gem 'maskmoney-rails'
gem 'country_select', github: 'stefanpenner/country_select'

# Frontend
gem 'bootstrap-sass', '~> 3.1.1'
gem 'font-awesome-rails'
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

# Others
gem 'friendly_id'
gem 'bitmask_attributes'
gem 'sdoc', '~> 0.4.0',          group: :doc

group :production do
  gem 'heroku-deflater'
  gem 'rails_12factor'

  # Error monitoring
  gem 'bugsnag'

  # Memory profiling
  # gem 'oink'
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
  gem "bullet"
  gem "rails_best_practices"
end

# Test data generation
gem 'faker'

group :test do
  # gem 'database_cleaner'
  # gem 'capybara'
  # gem 'selenium-webdriver'
end