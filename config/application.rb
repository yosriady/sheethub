require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

AWS.config({
  :access_key_id => 'AKIAI32VLLBYAJJ2THYA',
  :secret_access_key => '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',
  :region => 'ap-southeast-1'
})

module Sheethub
  class Application < Rails::Application

    ActsAsTaggableOn.remove_unused_tags = true
    ActsAsTaggableOn.force_lowercase = true
    ActsAsTaggableOn.force_parameterize = true
  end
end
