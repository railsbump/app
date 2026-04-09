module FeatureFlags
  def self.new_check_flow?
    ENV["ENABLE_NEW_CHECK_FLOW"] == "1"
  end
end
