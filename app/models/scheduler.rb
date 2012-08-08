class Scheduler
  @@scheduler = Rufus::Scheduler.start_new
  
  def self.instance
    @@scheduler
  end
  
  def self.stop
    # Stop all jobs
    @@scheduler.stop
    @@scheduler.jobs.each{|key, job| job.unschedule}
  end
  
  # Simulate delay_job. Should use DelayedJob instead of this (when we buy more worker on Heroku :)
  #
  # === Parameters
  #
  #   * force (bool): force run the block of code in background thread.
  #       If the value is false, this method will auto detect the current mode of Rails.
  #       Because there will be error when running background job in development mode.
  #       Default value is false.
  #   
  #   * delay_time (String): timestamp to pass to Rufus scheduler, ex: '1s', '20m', '1h',...
  #       Default value is '1s'. It means that the block of code will run immediately in another thread.
  #
  def self.delay(force = false, delay_time = "1s")
    if force || Rails.application.config.cache_classes
      self.instance.in delay_time do
        yield
      end
    else
      # Non-delay
      yield
    end
  end
end
