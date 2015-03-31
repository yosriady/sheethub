class SheetSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :slug, :title, :description, :price_cents, :pay_what_you_want, :likes, :genres, :composers, :sources, :publishers, :preview, :pdf, :assets, :created_at, :updated_at
  has_many :assets

  def genres
    object.cached_genres
  end

  def composers
    object.cached_composers
  end

  def sources
    object.cached_sources
  end

  def publishers
    object.cached_publishers
  end

  def additional_files
    object.assets_count
  end

  def likes
    object.cached_votes_total
  end

  def preview
    {
      url: object.pdf_preview_url,
    }
  end

  def pdf
    {
      pages: object.pages,
      filename: object.pdf_file_name,
      filetype: object.pdf_content_type,
      filesize: object.pdf_file_size,
      updated_at: object.pdf_updated_at
    }
  end
end
