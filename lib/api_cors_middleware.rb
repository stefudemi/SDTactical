class ApiCorsMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless env["PATH_INFO"].start_with?("/api/")

    headers = cors_headers(env)
    return [ 204, headers, [] ] if env["REQUEST_METHOD"] == "OPTIONS"

    status, response_headers, body = @app.call(env)
    [ status, response_headers.merge(headers), body ]
  end

  private

  def cors_headers(env)
    origin = env["HTTP_ORIGIN"]
    allowed_origin = ENV.fetch("FRONTEND_ORIGIN", "http://localhost:5173")
    return {} unless origin == allowed_origin

    {
      "Access-Control-Allow-Origin" => allowed_origin,
      "Access-Control-Allow-Methods" => "GET, POST, DELETE, OPTIONS",
      "Access-Control-Allow-Headers" => "Authorization, Content-Type",
      "Vary" => "Origin"
    }
  end
end
