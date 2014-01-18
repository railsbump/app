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
    excluded     = gem_names - EXCLUDED
    registered   = Rubygem.alphabetical.where name: excluded
    unregistered = excluded - registered.map(&:name)

    [registered, unregistered]
  end

  private

  def gem_names
    gemfile.scan(/^[ \t]*gem\s+['"](\S+)['"]/).flatten
  end
end
