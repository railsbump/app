module RailsReleases
  class Process < Services::Base
    def call(rails_release)
      Compat.where.not(rails_release: rails_release).find_each do |compat|
        rails_release.compats.where(dependencies: compat.dependencies).first_or_create!
      end

      Compats::CheckAllUnchecked.call
    end
  end
end
