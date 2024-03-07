require "sitemap_generator"

SitemapGenerator::Sitemap.default_host = root_url

SitemapGenerator::Sitemap.create do
  add new_gemmy_path
  add new_lockfile_path

  Gemmy.find_each do |gemmy|
    add gemmy_path(gemmy), lastmod: gemmy.updated_at
  end
end
