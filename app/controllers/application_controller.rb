class ApplicationController < ActionController::Base
  include Baseline::ControllerExtensions

  layout -> { false if request.format.js? }
end
