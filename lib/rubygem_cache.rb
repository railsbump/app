module RubygemCache
  extend self

  def find_by_name name
    Rails.cache.fetch ["rubygem", name] { Rubygem.find_by! name: name }
  end

  def flush_cache gem
    Rails.cache.delete ["rubygem", gem.name]
    Rails.cache.delete ["rubygems", "count"]
    Rails.cache.delete_if { |k, _| k == "recent" }
  end

  def recent scope
    gems = Rails.cache.fetch ["recent", scope.current_page] { scope.recent.to_a }
    Kaminari::PaginatableArray.new gems, limit: scope.limit_value, offset: scope.offset_value, total_count: cached_count
  end

  def cached_count
    Rails.cache.fetch ["rubygems", "count"] { Rubygem.count }
  end
end
