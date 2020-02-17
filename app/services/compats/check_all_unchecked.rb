module Compats
  class CheckAllUnchecked < Services::Base
    workers 1

    def call
      check_uniqueness

      Compat.unchecked.each do |compat|
        Compats::Check.call compat
      end
    end
  end
end
