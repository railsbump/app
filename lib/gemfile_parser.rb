class GemfileParser
  attr_reader :gemfile

  EXCLUDED = ["rails"]

  def self.gems gemfile
    new(gemfile).gems
  end

  def initialize gemfile
    @gemfile = gemfile
  end

  def gems
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
