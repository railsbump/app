module Compats
  class CheckUnchecked < Baseline::Service
    def call
      check_uniqueness

      Compat.unchecked.limit(100).find_each do |compat|
        Compats::Check.call compat
      end
    end
  end
end
