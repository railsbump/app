module Compats::Checks

  # This method checks if the dependencies include any Rail gems, and if so,
  # if any of them have a different version than the compat's Rails version.
  #
  # If that's the case, the compat is marked as incompatible.
  class RailsGemsCheck < Base
    RAILS_GEMS = %w(
      actioncable
      actionmailbox
      actionmailer
      actionpack
      actiontext
      actionview
      activejob
      activemodel
      activerecord
      activestorage
      activesupport
      rails
      railties
    )

    def call
      return unless @compat.pending?

      @compat.dependencies.each do |gem_name, requirement|
        next unless RAILS_GEMS.include?(gem_name)
        requirement_unmet = requirement.split(/\s*,\s*/).any? do |r|
          !Gem::Requirement.new(r).satisfied_by?(@compat.rails_release.version)
        end
        if requirement_unmet
          @compat.status               = :incompatible
          @compat.status_determined_by = "rails_gems"
          @compat.checked!
          return
        end
      end
    end
  end
end