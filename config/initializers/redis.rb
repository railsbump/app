# frozen_string_literal: true

require 'connection_pool'

Redis.current = ConnectionPool::Wrapper.new(size: 10) do
  Redis.new url: ENV.fetch('REDIS_URL')
end
