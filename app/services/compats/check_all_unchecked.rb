module Compats
  class CheckAllUnchecked < Services::Base
    def call
      check_uniqueness on_error: :return

      Compat.unchecked.find_each do |compat|
        Compats::Check.call compat
      end
    end
  end
end
