module RailsReleases
  class Process < Services::Base
    def call(rails_release)
      Gemmy.find_each do |gemmy|
        gemmy.versions.each do |version|
          gemmy.compats.where(
            rails_release: rails_release,
            version:       version
          ).first_or_create!
        end

        Compats::FindGroupedByDependencies.call(gemmy).values.each do |compats|
          compat = compats.detect { |compat| compat.rails_release == rails_release }
          Compats::Check.call compat
        end
      end
    end
  end
end
