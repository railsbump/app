require_dependency "gemfile_parser"

class GemfilesController < ApplicationController
  def new
  end

  def create
    @gems = Rubygem.where name: GemfileParser.gem_names(params[:gemfile])
  end
end
