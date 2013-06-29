require_dependency "gemfile_parser"

class GemfilesController < ApplicationController
  def new
  end

  def create
    parsed_gems = GemfileParser.gems params[:gemfile]
    @gems = Rubygem.where name: parsed_gems
  end
end
