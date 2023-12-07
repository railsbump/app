module Compats
  class CheckAllUnchecked < Baseline::Service
    def call
      check_uniqueness

      Compat.unchecked.find_each do |compat|
        Compats::Check.call compat
      end
    end
  end
end
