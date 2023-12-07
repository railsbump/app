class RefreshSitemap < Baseline::Service
  def call
    SitemapGenerator.verbose = false
    SitemapGenerator::Interpreter.run
  end
end
