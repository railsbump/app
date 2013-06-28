class GemfileParser
  attr_reader :gemfile

  def initialize gemfile
    @gemfile = gemfile
  end

  def gems
    gemfile
      .scan(/gem\s+['"](\w+)['"]/)
      .flatten
      .reject { |gem| gem == "rails" }
      .map { |gem| Rubygem.by_name(gem).first }
      .compact
  end
end
