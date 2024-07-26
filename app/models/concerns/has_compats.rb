module HasCompats
  # def compats
  #   gemmies = is_a?(Gemmy) ? self.class.where(id: self) : self.gemmies
  #   Compat.where(id: gemmies.from("#{Gemmy.table_name}, json_each(#{Gemmy.table_name}.compat_ids)").select("json_each.value"))
  # end
  def compats
    Compat.where("id IN (SELECT value::bigint FROM json_array_elements_text(?))", compat_ids.to_json)
  end
end
