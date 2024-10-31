require "fog-aws"

SitemapGenerator::Sitemap.default_host = "https://www.railsbump.org"
SitemapGenerator::Sitemap.public_path = "tmp/sitemaps/"  # Temporary storage before uploading to S3
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new(
  fog_provider: "AWS",
  fog_directory: "railsbump.org",
  fog_region: ENV["AWS_REGION"],
  aws_bucket: "railsbump.org",
  aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
  aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
  aws_region: ENV["AWS_REGION"]
)

opts = {
  create_index: true,
  default_host: "https://www.railsbump.org",
  compress: false,
  public_path: "/tmp",
  sitemaps_host: ENV["FOG_URL"],
  sitemaps_path: ""
}

SitemapGenerator::Sitemap.create opts do
  # Add static paths
  add root_path, changefreq: "daily", priority: 1.0
  add new_gemmy_path, changefreq: "monthly"
  add new_lockfile_path, changefreq: "monthly"

  # Add dynamic paths for all gemmies
  Gemmy.find_each do |gemmy|
    add gemmy_path(gemmy), lastmod: gemmy.updated_at, changefreq: "weekly", priority: 0.8
  end
end