class GemfileParser
  attr_reader :gemfile

  EXCLUDED = ["rails"]

  def self.gem_names gemfile
    new(gemfile).gem_names
  end

  def initialize gemfile
    @gemfile = gemfile
  end

  def gem_names
    gems_without_excluded.sort
  end

  private

  def gems_without_excluded
    gems_array.reject { |gem| EXCLUDED.include? gem }
  end

  def gems_array
    gemfile.scan(/gem\s+['"](\w+)['"]/).flatten
  end
end
