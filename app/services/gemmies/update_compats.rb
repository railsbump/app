require "gems"

module Gemmies
  class UpdateCompats < Baseline::Service
    def call(gemmy)
      check_uniqueness gemmy.id

      RailsRelease.find_each do |rails_release|
        gemmy.dependencies.each do |dependencies|
          rails_release
            .compats
            .where("dependencies::jsonb = ?", dependencies.to_json)
            .first_or_create!
        end
      end

      compats = Compat.where("dependencies::jsonb = ?", gemmy.dependencies.to_json)
      gemmy.update! compat_ids: compats.pluck(:id).sort
    end
  end
end
