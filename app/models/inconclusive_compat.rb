class InconclusiveCompat < Compat
  def compatible
    []
  end

  def inconclusive
    [self]
  end

  def pending
    []
  end

  def none?
    true
  end
end
