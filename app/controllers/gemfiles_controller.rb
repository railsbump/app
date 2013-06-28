class GemfilesController < ApplicationController
  def new
  end

  def create
    @gems = params[:gemfile]
              .scan(/gem\s+['"](\w+)['"]/)
              .flatten
              .reject { |gem| gem == "rails" }
              .map { |gem| Rubygem.by_name(gem).first }
              .compact
  end
end
