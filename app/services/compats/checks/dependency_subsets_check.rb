module Compats::Checks

  # This method checks if any other compats exist, that are marked as incompatible
  # and have a subset of the compat's dependencies.
  #
  # If so, the compat must be incompatible and is marked as such.
  class DependencySubsetsCheck < Base
    def call
      return unless @compat.pending? && (2..10).cover?(@compat.dependencies.size)

      subsets = (1..@compat.dependencies.size - 1).flat_map do |count|
        @compat.dependencies.keys.combination(count).map { @compat.dependencies.slice *_1 }
      end

      subsets.in_groups_of(100, false).each do |group|
        if @compat.rails_release.compats.where("dependencies::jsonb = ?", group.to_json).incompatible.any?
          @compat.status               = :incompatible
          @compat.status_determined_by = "dependency_subsets"
          @compat.checked!
          return
        end
      end
    end
  end
end