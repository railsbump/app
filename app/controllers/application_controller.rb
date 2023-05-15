# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout -> { false if request.format.js? }

  def health
    Gemmy.count
    expires_now
    head :ok
  end
end
