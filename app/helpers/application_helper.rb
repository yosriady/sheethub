module ApplicationHelper

  def tag_path(tag)
    context = tag.taggings[0].context #TODO: optimize SQL querying with includes?
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

  def tag_glyphicon(tag)
    context = tag.taggings[0].context #TODO: optimize SQL querying with includes?
    case context
    when "genres"
      "headphones"
    when "composers"
      "user"
    when "sources"
      "screenshot"
    else
      "music"
    end
  end

  def title(page_title)
    content_for :title, page_title.to_s + " | " if page_title
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

  def glyphicon_for flash_type
    case flash_type.to_sym
      when :success
        "ok"
      when :error
        "remove"
      when :alert
        "warning-sign"
      else
        "ok"
    end
  end

end
