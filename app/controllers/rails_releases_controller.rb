class RailsReleasesController < ApplicationController
  def show
    if rand < 0.01
      Sentry.capture_message(
        "GET /gems/:gemmy_id/compatibility/:id hit (legacy compat page, 1% sample)",
        level: :info,
        extra: {
          gemmy_id:   params[:gemmy_id],
          rails_id:   params[:id],
          remote_ip:  request.remote_ip,
          user_agent: request.user_agent,
          referer:    request.referer
        }
      )
    end

    @gemmy = Gemmy.find_by_name!(params[:gemmy_id])
    @rails_release = RailsRelease.find_by!(version: params[:id].gsub("rails-", "").gsub("-", "."))
  end
end
