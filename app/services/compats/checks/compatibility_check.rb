module Compats::Checks
  class CompatibilityCheck < Base
    def call
      return unless @compat.pending?

      check!
    end

    def check!
      result = @compat.direct_resolver.call

      if result.compatible?
        @compat.status               = :compatible
        @compat.status_determined_by = "DirectResolver"
        @compat.checked!
      else
        @compat.status               = :incompatible
        @compat.status_determined_by = "DirectResolver"
        @compat.checked!
      end
    end
  end
end
