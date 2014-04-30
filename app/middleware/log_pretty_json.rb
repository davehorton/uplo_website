class LogPrettyJson
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)

    if defined?(Rails) && headers["Content-Type"] =~ /^application\/json/
      obj = JSON.parse(response.body)
      pretty_str = JSON.pretty_unparse(obj)
      Rails.logger.debug(pretty_str)
    end

    [status, headers, response]
  end
end