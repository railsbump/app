class RailsReleasesController < ApplicationController
  def show
    @gemmy = Gemmy.find_by!(name: params[:gemmy_id])
    @rails_release = RailsRelease.find_by!(version: params[:id].gsub("rails-", "").gsub("-", "."))
  end
end