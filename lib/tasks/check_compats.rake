task :check_compats do
  Compats::CheckAllUnchecked.call
end
