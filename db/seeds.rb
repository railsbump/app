require 'gems'

# Rails Releases

RailsRelease.destroy_all

Gems.versions('rails').each do |data|
  RailsReleases::Create.call(data.fetch('number'))
end

# Gemmies

Gemmy.destroy_all

%w(
  rspec
  minitest
  nokogiri
  addressable
  aws-sdk
  faraday
).each do |name|
  Gemmies::Create.call(name)
end
