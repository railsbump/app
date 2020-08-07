require 'gems'

module Gemmies
  class FindOrCreateCompats < Services::Base
    def call(gemmy)
      check_uniqueness gemmy.id, on_error: :return

      RailsRelease.latest_major.map do |rails_release|
        gemmy.dependencies.flat_map do |dependencies|
          rails_release.compats.where(dependencies: dependencies).first_or_create!
        end
      end
    end
  end
end
