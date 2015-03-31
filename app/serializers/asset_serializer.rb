class AssetSerializer < ActiveModel::Serializer
  attributes :filename, :filetype, :filesize, :updated_at
end
