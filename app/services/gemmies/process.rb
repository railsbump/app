module Gemmies
  class Process < Services::Base
    def call(gemmy)
      gemmy.versions.each do |version|
        RailsRelease.find_each do |rails_release|
          gemmy.compats.where(
            rails_release: rails_release,
            version:       version
          ).first_or_create!
        end
      end

      Compats::FindGroupedByDependencies.call(gemmy).values.each do |compats|
        compats.uniq(&:rails_release).each do |compat|
          Compats::Check.call_async compat
        end
      end
    end
  end
end
