require 'gems'

module Gemmies
  class FindOrCreateCompats < Services::Base
    def call(gemmy)
      check_uniqueness gemmy.id, on_error: :return

      RailsRelease.find_each do |rails_release|
        gemmy.dependencies.each do |dependencies|
          rails_release.compats.where(dependencies: dependencies).first_or_create!
        end
      end
    end
  end
end
