module HasCompats
  def compats
    dependencies = is_a?(Gemmy) ? self.dependencies : gemmies.flat_map(&:dependencies).uniq
    Compat.where(dependencies: dependencies)
  end
end
