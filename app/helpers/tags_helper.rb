module TagsHelper
  def cache_key_for_tag_breadcrumb(tag)
    "tag_breadcrumb_#{tag}"
  end

  def cache_key_for_tags(tags)
    "tags_#{tags.hash}"
  end
end