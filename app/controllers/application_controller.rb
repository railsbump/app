class ApplicationController < ActionController::Base
  layout -> { false if request.format.js? }
end
