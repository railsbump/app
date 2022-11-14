# frozen_string_literal: true

require "gems"

module Gemmies
  class UpdateCompats < Baseline::Service
    def call(gemmy)
      check_uniqueness gemmy.id, on_error: :return

      RailsRelease.find_each do |rails_release|
        gemmy.dependencies.each do |dependencies|
          rails_release.compats.where(dependencies: dependencies)
                               .first_or_create!
        end
      end

      # Don't use `Compat.where(dependencies: gemmy.dependencies)`, the generated SQL is
      # missing parentheses around the WHERE conditions and therefore doesn't work.
      compats = Compat.where(%(dependencies IN (?)), gemmy.dependencies.map(&JSON.method(:generate)))
      gemmy.update! compat_ids: compats.pluck(:id).sort
    end
  end
end
