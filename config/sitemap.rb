# frozen_string_literal: true

require "sitemap_generator"
require "aws-sdk-s3"

SitemapGenerator::Sitemap.default_host = Rails.application.routes.url_helpers.root_url
SitemapGenerator::Sitemap.adapter      = SitemapGenerator::AwsSdkAdapter.new(
                                           ENV.fetch("CLOUDFLARE_R2_BUCKET"),
                                           access_key_id:     ENV.fetch("CLOUDFLARE_R2_ACCESS_KEY_ID"),
                                           secret_access_key: ENV.fetch("CLOUDFLARE_R2_SECRET_ACCESS_KEY"),
                                           endpoint:          "https://#{ENV.fetch "CLOUDFLARE_ACCOUNT_ID"}.r2.cloudflarestorage.com",
                                           region:            "auto"
                                         )

SitemapGenerator::Sitemap.create do
  add new_gemmy_path
  add new_lockfile_path

  Gemmy.find_each do |gemmy|
    add gemmy_path(gemmy), lastmod: gemmy.updated_at
  end
end
