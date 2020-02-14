class CompatsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :table

  def table
    @compats = JSON.load(params[:compats]).map do |global_ids|
      global_ids.map(&GlobalID::Locator.method(:locate))
    end
  end
end
