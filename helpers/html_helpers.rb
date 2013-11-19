# Adapted from sinatra-support/htmlhelpers.rb
# (https://github.com/sinefunc/sinatra-support/)
#
module HtmlHelpers
  def select_options pairs, current = nil
    pairs.map do |label, value|
      tag :option, label, value: value, selected: (current == value)
    end.join "\n"
  end

  def tag tag, content, attributes = {}
    if self_closing_tag?(tag)
      "<#{ tag }#{ tag_attributes(attributes) } />"
    else
      "<#{ tag }#{ tag_attributes(attributes) }>#{h content}</#{ tag }>"
    end
  end

  def tag_attributes attributes = {}
    attributes.inject([]) do |attribute, (key, value)|
      attribute << (' %s="%s"' % [key, escape_attribute(value)]) if value
      attribute
    end.join
  end

  def escape_attribute attribute
    attribute.to_s.gsub("'", '&#39;').gsub '"', '&quot;'
  end

  SELF_CLOSING_TAGS = [:area, :base, :basefont, :br, :hr, :input, :img, :link, :meta]

  def self_closing_tag? tag
    SELF_CLOSING_TAGS.include? tag.to_sym
  end

  def h str
    Rack::Utils.escape_html str
  end
end
