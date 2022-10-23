class RefreshSitemap < Services::Base
  SitemapGenerator.verbose = false
  SitemapGenerator::Interpreter.run
end
