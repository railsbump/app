require 'sitemap_generator'
require 'aws-sdk-s3'

SitemapGenerator::Sitemap.default_host  = 'https://railsbump.org'
SitemapGenerator::Sitemap.sitemaps_host = 'https://railsbump.s3.eu-central-1.amazonaws.com'
SitemapGenerator::Sitemap.adapter       = SitemapGenerator::AwsSdkAdapter.new('railsbump')
SitemapGenerator::Sitemap.compress      = false
SitemapGenerator::Sitemap.create do
  add new_gemmy_path
  add new_lockfile_path

  Gemmy.find_each do |gemmy|
    add gemmy_path(gemmy), lastmod: gemmy.updated_at
  end
end
