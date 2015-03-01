module ApplicationHelper

  def url_with_protocol(url)
    /^http/i.match(url) ? url : "http://#{url}"
  end

  def tag_url(tag_type, tag)
    case tag_type
    when 'genre'
      genre_url(tag)
    when 'composer'
      composer_url(tag)
    when 'source'
      source_url(tag)
    else
      ''
    end
  end

  def tag_icon(tag_type)
    case tag_type
    when 'genre'
      'headphones'
    when 'composer'
      'users'
    when 'source'
      'book'
    when 'instrument'
      'magic'
    else
      'question'
    end
  end

  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :success
      'alert-success'
    when :error
      'alert-error'
    when :alert
      'alert-info'
    when :notice
      'alert-info'
    else
      flash_type.to_s
    end
  end

  def icon_for(flash_type)
    case flash_type.to_sym
    when :success
      'check'
    when :error
      'remove'
    when :alert
      'warning'
    else
      'check'
    end
  end

  def wikipedia_extract(key)
    require 'httparty'
    response = HTTParty.get("https://en.wikipedia.org/w/api.php?format=json&action=query&continue=&prop=extracts&exsentences=5&exintro=&explaintext=&titles=" + URI.escape(key.titleize))
    body = JSON.parse(response.body)["query"]["pages"]
    extract = body[body.keys()[0]]["extract"]
    has_valid_information = extract && !extract.index("This is a redirect") && extract.size > 100
    (has_valid_information) ? extract : nil
  end

end
