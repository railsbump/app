module RubygemCache
  extend self

  CACHE_KEY = Rubygem.name

  def total_count
    Rails.cache.fetch [CACHE_KEY, "total_count"] { Rubygem.count }
  end

  def count_by_status
    Rails.cache.fetch [CACHE_KEY, "count_by_status"] { Rubygem.group(:status).count }
  end

  def maximum_updated_at
    Rails.cache.fetch [CACHE_KEY, "maximum_updated_at"] { Rubygem.maximum :updated_at }
  end

  def find_by_name name
    Rails.cache.fetch [CACHE_KEY, name] { Rubygem.find_by! name: name }
  end

  def flush_by_gem gem
    Rails.cache.delete [CACHE_KEY, gem.name]
    flush
  end

  def flush
    Rails.cache.delete [CACHE_KEY, "count_by_status"]
    Rails.cache.delete [CACHE_KEY, "maximum_updated_at"]
    Rails.cache.delete [CACHE_KEY, "total_count"]
  end
end
