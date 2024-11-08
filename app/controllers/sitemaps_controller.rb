# app/controllers/sitemaps_controller.rb
class SitemapsController < ApplicationController
  require "open-uri"

  def show
    sitemap_url = ENV["FOG_URL"]
    if sitemap_url.present?
      sitemap_content = URI.open("#{sitemap_url}/sitemap.xml").read
      send_data sitemap_content, type: "application/xml", disposition: "inline"
    else
      head :not_found
    end
  end
end