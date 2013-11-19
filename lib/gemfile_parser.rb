class GemfileParser
  def initialize gemfile
    @gemfile = gemfile
  end

  def gems
    @gemfile.scan(/gem\s+['"](\S+)['"]/).flatten
  end
end
