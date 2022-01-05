module HasCompats
  def compats
    gemmies = is_a?(Gemmy) ? self.class.where(id: self) : self.gemmies
    Compat.where(id: gemmies.select("unnest(compat_ids::bigint[])"))
  end
end
