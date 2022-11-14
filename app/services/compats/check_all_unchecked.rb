# frozen_string_literal: true

module Compats
  class CheckAllUnchecked < Baseline::Service
    def call
      check_uniqueness on_error: :return

      Compat.unchecked.find_each do |compat|
        Compats::Check.call compat
      end
    end
  end
end
