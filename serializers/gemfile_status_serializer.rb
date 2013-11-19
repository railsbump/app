require_relative 'rubygem_serializer'

class GemfileStatusSerializer < JsonSerializer
  attribute :registered, RubygemSerializer
  attribute :unregistered
end
