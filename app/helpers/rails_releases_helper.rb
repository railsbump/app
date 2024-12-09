module RailsReleasesHelper
  def head_title
    if @gemmy
      if @rails_release
        "#{@gemmy} gem: Compatibility with #{@rails_release}"
      else
        rails_releases = RailsRelease.order(:version)
        first_version = rails_releases.first.version
        last_version = rails_releases.last.version
        "#{@gemmy} gem: Compatibility with Rails #{first_version} to #{last_version}"
      end
    else
      super
    end
  end

  def meta_description
    if @gemmy
      if @rails_release
        "RailsBump calculated the compatibility status for the #{@gemmy} gem and #{@rails_release}. Is #{@gemmy} compatible with #{@rails_release}?"
      else
        rails_releases = RailsRelease.order(:version)
        first_version = rails_releases.first.version
        last_version = rails_releases.last.version
        "RailsBump calculated #{@gemmy}'s compatibility with Rails #{first_version} to #{last_version}. How compatible the #{@gemmy} gem is with different versions of Rails?"
      end
    else
      super
    end
  end
end
