class GemfileStatus
  EXCLUDED = ['rails']

  def initialize gems
    @gems = gems - EXCLUDED
  end

  def registered
    Rubygem.where(name: @gems).all
  end

  def unregistered
    @gems - registered.map(&:name)
  end
end
