# app/controllers/sitemaps_controller.rb
class SitemapsController < ApplicationController
  require "open-uri"

  def show
    sitemap_url = ENV["FOG_URL"]
    if sitemap_url.present?
      send_data open(sitemap_url).read, type: "application/xml", disposition: "inline"
    else
      head :not_found
    end
  end
end