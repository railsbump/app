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
      compat                                      = gemmy.compats.find_by!(rails_release: rails_release, version: gemmy_version)

      travis_notification.update! compat: compat

      compatible = travis_notification.data.fetch('status') == 0

      compat_groups = Compats::FindGroupedByDependencies.call(gemmy).values
      compat_groups.detect do |compat_group|
        compat_group.include?(compat)
      end.select do |rc|
        rc.rails_release == compat.rails_release
      end.each do |rc|
        rc.update! compatible: compatible
      end

      unless compatible
        build_url = travis_notification.data.fetch('build_url')
        Rollbar.error "#{compat} has been marked as not compatible. Check Travis results!", build_url: build_url
      end

      travis_notification.processed!
    end
  end
end
