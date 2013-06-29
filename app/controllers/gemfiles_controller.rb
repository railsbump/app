require_dependency "gemfile_parser"

class GemfilesController < ApplicationController
  def new
  end

  def create
    @gems = Rubygem.where name: GemfileParser.gems(params[:gemfile])
  end
end
