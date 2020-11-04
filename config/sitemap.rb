require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'https://railsbump.org'
SitemapGenerator::Sitemap.compress     = false
SitemapGenerator::Sitemap.create do
  add new_gemmy_path
  add new_lockfile_path

  Gemmy.find_each do |gemmy|
    add gemmy_path(gemmy)
  end
end
