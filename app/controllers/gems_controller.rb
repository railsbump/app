class GemsController < ApplicationController
  def index
    scope = Rubygem.alphabetically

    @gems = if params[:query].present?
      scope.search_by_name params[:query]
    else
      scope
    end
  end
end
