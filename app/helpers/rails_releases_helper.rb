module RailsReleasesHelper
  def head_title
    if @gemmy
      if @rails_release
        "#{@gemmy} gem: Compatibility with #{@rails_release}"
      else
        rails_releases = RailsRelease.order(:version)
        first_version = rails_releases.first.version
        last_version = rails_releases.last.version
        "#{@gemmy} gem: Compatibility with Rails versions (from Rails #{first_version} to #{last_version})"
      end
    else
      super
    end
  end
end
