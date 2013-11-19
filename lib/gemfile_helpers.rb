module GemfileHelpers
  def link_gems names
    names.map { |name| tag(:a, name, href: "/gems/new?name=#{ name }") }
  end

  def to_sentence ary
    "#{ ary[0...-1].join(',') } and #{ ary[-1] }"
  end
end
