module TravisNotifications
  class Process < Services::Base
    def call(travis_notification)
      if travis_notification.processed?
        raise Error, "Travis Notification #{travis_notification.id} has already been processed."
      end

      branch                                      = travis_notification.data.fetch('branch')
      gemmy_name, gemmy_version, _, rails_version = branch.split('_')
      gemmy                                       = Gemmy.find_by!(name: gemmy_name)
      rails_release                               = RailsRelease.find_by!(version: rails_version)
      rails_compatibility                         = gemmy.rails_compatibilities.find_by!(rails_release: rails_release, version: gemmy_version)

      travis_notification.update! rails_compatibility: rails_compatibility

      compatible = travis_notification.data.fetch('status') == 0

      rails_compatibility_groups = RailsCompatibilities::FindGroupedByDependencies.call(gemmy).values
      rails_compatibility_groups.detect do |rails_compatibility_group|
        rails_compatibility_group.includes?(rails_compatibility)
      end.select do |rc|
        rc.rails_release == rails_compatibility.rails_release
      end.each do |rc|
        rc.update! compatible: compatible
      end

      unless compatible
        build_url = travis_notification.data.fetch('build_url')
        Rollbar.error "#{rails_compatibility} has been marked as not compatible. Check Travis results!", build_url: build_url
      end

      travis_notification.processed!
    end
  end
end
