module HasCompats
  def compats
    gemmies = is_a?(Gemmy) ? self.class.where(id: self) : self.gemmies
    Compat.where(id: gemmies.from("#{Gemmy.table_name}, json_each(#{Gemmy.table_name}.compat_ids)").select("json_each.value"))
  end
end
