module Compats::Checks

  # This method checks for the simplest case: if the compat has no dependencies,
  # it's marked as compatible.
  class EmptyDependenciesCheck < Base
    def call
      return unless @compat.pending?

      check!
    end

    def check!
      if @compat.dependencies.blank?
        @compat.status               = :compatible
        @compat.status_determined_by = "empty_dependencies"
        @compat.checked!
      end
    end
  end
end