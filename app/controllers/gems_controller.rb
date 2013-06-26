class GemsController < ApplicationController

  def index
    @gems = Rubygem.alphabetically
  end

end
