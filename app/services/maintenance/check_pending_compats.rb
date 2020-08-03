module Maintenance
  class CheckPendingCompats < Services::Base
    def call
      check_uniqueness on_error: :return

      pending_compats = Compat.pending
                              .checked_before?(2.hours.ago)

      if pending_compats.any?
        raise Error, 'Some compats have been pending for a long time.' \
          rescue Rollbar.error $!, compat_ids: pending_compats.map(&:id)
      end
    end
  end
end
