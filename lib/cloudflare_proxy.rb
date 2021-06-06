# https://bloggie.io/@kinopyo/heroku-free-dyno-with-cloudflare-free-ssl
class CloudflareProxy
  def initialize(app)
    @app = app
  end

  def call(env)
    if cloudflare_header = env["HTTP_CF_VISITOR"]
      env["HTTP_X_FORWARDED_PROTO"] = JSON.parse(cloudflare_header)["scheme"]
    end

    @app.call(env)
  end
end
