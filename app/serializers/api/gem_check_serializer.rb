module API
  class GemCheckSerializer
    def initialize(gem_check)
      @gem_check = gem_check
    end

    def as_json(*)
      {
        name: @gem_check.gem_name,
        locked_version: @gem_check.locked_version,
        status: @gem_check.status,
        result: @gem_check.result,
        earliest_compatible_version: @gem_check.earliest_compatible_version,
        error_message: @gem_check.error_message
      }
    end
  end
end
