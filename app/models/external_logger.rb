class ExternalLogger
  def log_error(exception, description, params_as_hash=nil)
    # log in the server log just in case external service is down
    Rails.logger.warn("#{description}: #{exception.message}")

    opts = {
      error_class: "System Error",
      error_message: description,
      parameters: params_as_hash
    }

    Honeybadger.notify(exception, opts)
  end
end
