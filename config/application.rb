require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sheethub
  class Application < Rails::Application
    config.autoload_paths << Rails.root.join('lib')

    # Paperclip file storage config
    config.paperclip_defaults = {
      storage: :s3,
      s3_credentials: {
        bucket: Rails.application.secrets.s3_bucket,
        access_key_id: Rails.application.secrets.s3_access_key_id,
        secret_access_key: Rails.application.secrets.s3_secret_access_key,
        region: Rails.application.secrets.s3_region
      }
    }

    config.to_prepare { Devise::Mailer.layout "mailer" }

    ActsAsTaggableOn.remove_unused_tags = true
    ActsAsTaggableOn.force_lowercase = true
    ActsAsTaggableOn.force_parameterize = true

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end

