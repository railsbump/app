require_dependency "gemfile_parser"

class GemfilesController < ApplicationController
  def new
  end

  def create
    @gems = GemfileParser.new(params[:gemfile]).gems
  end
end
