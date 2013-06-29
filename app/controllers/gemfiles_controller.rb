require_dependency "gemfile_parser"

class GemfilesController < ApplicationController
  def new
  end

  def create
    @gems = GemfileParser.gems_status params[:gemfile]
  end
end
