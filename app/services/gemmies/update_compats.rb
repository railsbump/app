require 'gems'

module Gemmies
  class UpdateCompats < Services::Base
    def call(gemmy)
      check_uniqueness gemmy.id, on_error: :return

      RailsRelease.find_each do |rails_release|
        gemmy.dependencies.each do |dependencies|
          rails_release.compats.where(dependencies: dependencies)
                               .first_or_create!
        end
      end

      compats = Compat.where(dependencies: gemmy.dependencies)
      gemmy.update! compat_ids: compats.pluck(:id).sort
    end
  end
end
