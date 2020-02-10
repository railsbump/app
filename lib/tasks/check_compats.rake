task :check_compats do
  gemmies = Gemmy.joins(:compats).where(compats: { compatible: nil }).distinct

  gemmies.each do |gemmy|
    Compats::FindGroupedByDependencies.call(gemmy).values.each do |compats|
      compats.uniq(&:rails_release).select(&:unchecked?).each do |compat|
        Compats::Check.call compat
      end
    end
  end
end
