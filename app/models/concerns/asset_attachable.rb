module AssetAttachable
  extend ActiveSupport::Concern

  included do
    INVALID_ASSETS_MESSAGE = 'Sheet supporting files invalid'

    has_many :assets, dependent: :destroy
    accepts_nested_attributes_for :assets
    validates_associated :assets,
                         on: [:create, :update],
                         message: INVALID_ASSETS_MESSAGE
  end
end