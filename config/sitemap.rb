require "sitemap_generator"

# is this needed?
# SitemapGenerator::Sitemap.default_host = Rails.application.routes.url_helpers.root_url

SitemapGenerator::Sitemap.create do
  add new_gemmy_path
  add new_lockfile_path

  Gemmy.find_each do |gemmy|
    add gemmy_path(gemmy), lastmod: gemmy.updated_at
  end
end
