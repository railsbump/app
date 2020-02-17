task check_compats: :environment do
  Compats::CheckAllUnchecked.call
end
