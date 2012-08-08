# Utility methods for model classes.
module Util
  class << self
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::DateHelper
    
    def format_money(number, options = {})
      options.symbolize_keys!
      options[:unit_included] = false unless options.keys.include?(:unit_included)
      perform_format_money(number, options)
    end

    def friendly_format_money(number)
      options = {:unit_included => true, :clear_space => false}
      perform_format_money(number, options)
    end

    # Round float number
    def round_f(f_num, precise=2)
      if precise.to_i <= 0
        precise = 1
      end
      precise = 10**precise
      result = (f_num * precise).round.to_f / precise
      
      i_result = result.to_i
      if result == result.to_i
        i_result
      else
        result
      end
    end

    def benchmark(process_name)
      start = Time.now
      yield
      time = (Time.now - start) * 1000
      Rails.logger.info "===== Finish #{process_name.to_s} in #{time} ms ====="
    end
    
    def trim_string(str)
      if str && str.is_a?(String)
        return str.strip! || str
      end
      return str
    end
    
    def format_date(value)
      begin
        value = DateTime.strptime(value.to_s, I18n.t("date.formats.default"))
      rescue Exception
        nil
      end
    end
    
    def date_to_string(date)
      begin
        date.strftime(I18n.t("date.formats.default"))
      rescue Exception
        ""
      end
    end
    
    def compare_decimals(num1, num2)
      return 0 if num1.nil? && num2.nil?
      return -1 if num1.nil?
      return 1 if num2.nil?
      
      tmp1 = (!num1.is_a?(Fixnum) ? num1.to_d : num1)
      tmp2 = (!num2.is_a?(Fixnum) ? num2.to_d : num2)
      return tmp1 <=> tmp2
    end
    
    def equal_decimals?(num1, num2)
      self.compare_decimals(num1, num2) == 0
    end
    
    def log_error(exc, description = "")
      Rails.logger.error "===== ERROR: #{description} ====="
      Rails.logger.error exc.inspect
      Rails.logger.error exc.backtrace.join("\n")
    end
  
    def merge_options(default_options, options)
      options ||= {}
      default_options.merge(options)
    end
    
    def url_helpers
      Rails.application.routes.url_helpers
    end
    
    def to_cents(money)
      (money*100).round
    end
  
    private

    def perform_format_money(number, options = {})
      return nil if number.nil?
      options.symbolize_keys!
      options[:locale] ||= I18n.locale
      options[:unit_included] = true unless options.has_key?(:unit_included)
      options[:clear_space] = true unless options.has_key?(:clear_space)
      unless options[:unit_included]
        options[:format] = "%n"
      end
      
      if !options.has_key?(:precision)
        options[:precision] = 0
        if number.to_s.include?(".") && number != number.to_i # Check float number
          options[:precision] = 2
        end
      end
      
      result = ""
      if number < 0
        result = "-" + number_to_currency(number*(-1), options)
      else
        result = number_to_currency(number, options)
      end
    
      if options[:clear_space] && result
        result = result.gsub(" ", "")
      end
      
      result
    end
  end
end
