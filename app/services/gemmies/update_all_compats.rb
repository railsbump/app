module Gemmies
  class UpdateAllCompats < Services::Base
    def call
      check_uniqueness

      key  = "update_all_compats_done"
      done = Redis.current.smembers(key)

      if done.size == Gemmy.count
        Rollbar.error "done, remove this service!"
        return
      end

      Gemmy.where.not(id: done).limit(200).each do |g|
        Gemmies::UpdateCompats.call(g)
        Redis.current.sadd key, g.id
      end

      Redis.current.expire key, 1.month
    end
  end
end
