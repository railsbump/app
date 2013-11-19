module GemfileHelpers
  def link_gems names
    names.map { |name| tag(:a, name, href: "/gems/new?name=#{ name }") }
  end

  def to_sentence items
    "#{ items[0...-1].join(',') } and #{ items[-1] }"
  end
end
