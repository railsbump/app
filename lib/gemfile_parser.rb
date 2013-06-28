class GemfileParser
  attr_reader :gemfile

  def self.gems_status gemfile
    new(gemfile).gems_status
  end

  def initialize gemfile
    @gemfile = gemfile
  end

  def gems_status
    gemfile
      .scan(/gem\s+['"](\w+)['"]/)
      .flatten
      .reject { |gem| gem == "rails" }
      .map { |gem| Rubygem.by_name(gem).first }
      .compact
  end
end
