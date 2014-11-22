module ApplicationHelper

  def url_with_protocol(url)
    /^http/i.match(url) ? url : "http://#{url}"
  end

  # TOOD: Refactor tag.taggings[0].context
  def tag_path(tag)
    context = tag.taggings[0].context
    case context
    when "genres"
      "/genre/#{tag.name}"
    when "composers"
      "/composer/#{tag.name}"
    when "sources"
      "/source/#{tag.name}"
    else
      "/404"
    end
  end

  def tag_icon(tag_type)
    case tag_type
    when "genre"
      "headphones"
    when "composer"
      "users"
    when "source"
      "book"
    else
      "magic"
    end
  end

  def bootstrap_class_for flash_type
    case flash_type.to_sym
      when :success
        "alert-success"
      when :error
        "alert-error"
      when :alert
        "alert-info"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  def icon_for flash_type
    case flash_type.to_sym
      when :success
        "check"
      when :error
        "remove"
      when :alert
        "warning"
      else
        "check"
    end
  end

end
