module HasVersion
  extend ActiveSupport::Concern

  included do
    composed_of :version,
      class_name: 'Gem::Version',
      mapping:    %w(version to_s),
      converter:  Gem::Version.method(:new)
  end
end
