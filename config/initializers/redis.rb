# frozen_string_literal: true

require "connection_pool"

redis_url = ENV.fetch("REDIS_URL") { "redis://localhost:6379/0" }

Redis.current = ConnectionPool::Wrapper.new(size: 10) do
  Redis.new url: redis_url
end
