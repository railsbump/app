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
    Rubygem.where(name: gems_without_excluded).to_a
  end

  private

  def gems_without_excluded
    gems.reject { |gem| EXCLUDED.include? gem }
  end

  def gems
    gemfile.scan(/gem\s+['"](\w+)['"]/).flatten
  end
end
