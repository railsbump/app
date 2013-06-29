class GemfileParser
  attr_reader :gemfile

  EXCLUDED = ["rails"]

  def self.gems_status gemfile
    new(gemfile).gems_status
  end

  def initialize gemfile
    @gemfile = gemfile
  end

  def gems_status
    Rubygem.alphabetical.where name: gem_names - EXCLUDED
  end

  private

  def gem_names
    gemfile.scan(/gem\s+['"](\w+)['"]/).flatten
  end
end
