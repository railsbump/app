module HasCompats
  def compats
    dependencies = is_a?(Gemmy) ? dependencies : gemmies.map(&:dependencies)
    Compat.where(dependencies: dependencies, rails_release: RailsRelease.latest_major)
  end
end
