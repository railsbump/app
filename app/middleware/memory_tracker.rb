class MemoryTracker
  RSS_SPIKE_THRESHOLD_MB = 5

  def initialize(app)
    @app = app
  end

  def call(env)
    rss_before = current_rss_mb
    status, headers, body = @app.call(env)
    rss_after  = current_rss_mb
    delta      = rss_after - rss_before

    if delta >= RSS_SPIKE_THRESHOLD_MB
      req = Rack::Request.new(env)
      Sentry.logger.warn(
        "memory spike detected",
        rss_before_mb: rss_before,
        rss_after_mb:  rss_after,
        delta_mb:      delta,
        method:        req.request_method,
        path:          req.path,
        query_string:  req.query_string.presence,
        remote_ip:     req.ip,
        user_agent:    req.user_agent,
        referer:       req.referer
      )
    end

    [ status, headers, body ]
  end

  private

  def current_rss_mb
    IO.read("/proc/#{Process.pid}/status")
      .match(/VmRSS:\s+(\d+)/)[1]
      .to_i / 1024.0
  rescue
    0.0
  end
end
