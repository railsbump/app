# frozen_string_literal: true

class RefreshSitemap < Services::Base
  def call
    SitemapGenerator.verbose = false
    SitemapGenerator::Interpreter.run
  end
end
