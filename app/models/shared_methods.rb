# This module contains shared methods that can be included or used across models
module SharedMethods
  module Paging
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    module InstanceMethods

    end

    module ClassMethods
      def paging_options(options, default_opts = {})
        info = PagingInfo.new

        options ||= {}
        options.to_options!

        if default_opts.blank?
          default_opts = {
            :sort_criteria => {:id => "DESC"},
            :page_id => 1
          }
        end

        page_id = default_opts[:page_id]
        #page_size = PAGE_SIZE

        if options[:page_id] && options[:page_id].to_i > 0
          info.page_id = options[:page_id]
        end

        if options[:page_size] && options[:page_size].to_i > 0
          info.page_size = options[:page_size]
        end

        if options[:sort_field]
          sort_field = options[:sort_field]
          sort_direction = options[:sort_direction] || "ASC"
          info.sort_string = "#{sort_field} #{sort_direction}"
          info.sort_criteria = {sort_field => sort_direction}
        else
          if default_opts[:sort_criteria].is_a?(String)
            info.sort_string = default_opts[:sort_criteria]
            info.sort_criteria = parse_sort_param(info.sort_string)
          elsif default_opts[:sort_criteria].is_a?(Hash)
            info.sort_string = sort_param_to_string(default_opts[:sort_criteria])
            info.sort_criteria = default_opts[:sort_criteria]
          else
            raise ArgumentError.new("Invalid options[:sort_criteria]. It should be a string or a hash.")
          end
        end

        return info
      end

      # Parse the input string with the format "sort_field1 sort_direction1, sort_field2 sort_direction2, ..." to a hash.
      def parse_sort_param(sort_param = "")
        params = sort_param.split(",")
        if params.blank?
          params = [sort_param]
        end
        result = {}
        params.each do |p|
          p.strip! # get the string "sort_field1 sort_direction1"
          criteria = p.split(" ")
          if criteria.blank?
            criteria = [p]
          end
          if criteria.length == 1
            result[criteria[0]] = "ASC" # default sort direction
          elsif criteria.length == 2
            result[criteria[0]] = criteria[1]
          end
        end
        return result
      end

      # Parse the input hash with the format {:sort_field1 => "sort_direction1", :sort_field2 => "sort_direction2""", ...} to a string.
      # This is the inverse method of parse_sort_param() method.
      def sort_param_to_string(sort_param = {})
        sort_param.collect{|k,v| "#{k} #{v}"}.join(",")
      end
    end
  end

  module SerializationConfig
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    module InstanceMethods
      # Override Rails as_json method
      def as_json(options={})
        if (!options.blank?)
          super(self.default_serializable_options.merge(options))
        else
          super(self.default_serializable_options)
        end
      end

      def exposed_methods
        self.class.exposed_methods
      end

      def exposed_attributes
        self.class.except_attributes
      end

      def exposed_associations
        self.class.exposed_associations
      end

      def except_attributes
        self.class.except_attributes
      end

      def default_serializable_options
        self.class.default_serializable_options
      end
    end

    module ClassMethods
      def exposed_methods
        []
      end

      def exposed_attributes
        []
      end

      def exposed_associations
        []
      end

      def except_attributes
        attrs = []
        self.attribute_names.each do |n|
          if !exposed_attributes.include?(n.to_sym)
            attrs << n
          end
        end
        attrs
      end

      def default_serializable_options
        { :except => self.except_attributes,
          :methods => self.exposed_methods,
          :include => self.exposed_associations
        }
      end
    end
  end

  module Converter
    def self.Boolean(string)
      string = string.to_s
      return true if string== true || string =~ (/(true|t|yes|y|1)$/i)
      return false if string== false || string.nil? || string =~ (/(false|f|no|n|0)$/i)
      raise ArgumentError.new("invalid value for Boolean: #{string}")
    end

    class FileSizeConverter
      UNITS = {:byte => 'b', :kilobyte => 'kb', :megabyte => 'mb', :gigabyte => 'gb', :tetrabyte => 'tb'}
      UNIT_ARRANCE = [UNITS[:byte], UNITS[:kilobyte], UNITS[:megabyte], UNITS[:gigabyte], UNITS[:tetrabyte]]

      def self.convert(size, from_unit, to_unit)
        gab = UNIT_ARRANCE.index(from_unit.downcase) - UNIT_ARRANCE.index(to_unit.downcase)
        pow = gab / gab.abs # 1 or -1
        (0...gab.abs).each{ size *= Float(2 ** (10 * pow)) }

        return size.round(3)
      end
    end

    class SearchStringConverter
      SPECIAL_CHARS = ["@", "&", "^", "~", "$", "!", "+", "-", "|", "{", "}", "?", "/", "\\", "<", ">", ";", ":", "#", "%", "*", "(", ")", "=", "\"", ".", "\,", "'", "\"", "_"]

      def self.contain_special_character?(str)
        SPECIAL_CHARS.each{|c| return true if str.index(c)}
        return false
      end

      def self.process_special_chars(str)
        str.gsub!(/\s+/, " ")
        start_space = 0
        end_space = str.index " "
        tmp = str
        idx = tmp.index(" ").nil? ? (tmp.length) : tmp.index(" ")

        while !tmp.nil? and tmp.length > 0
          idx = tmp.index(" ").nil? ? (tmp.length) : tmp.index(" ")
          end_space = tmp.index(" ").nil? ? (idx + start_space ) : (idx + start_space)
          sub_str = str[start_space, end_space]
          if self.contain_special_character?(sub_str)
            str.insert start_space, '*'
            str.insert (end_space + 1), '*'
            start_space = end_space + 3
          else
            start_space = end_space + 1
          end

          idx = tmp.index(" ").nil? ? (tmp.length) : tmp.index(" ")
          tmp = tmp[idx + 1, tmp.length - 1]
        end

        return str
      end
    end
  end

  module TimeCalculator
    MONS_PER_YEAR = 12
    DAYS_OF_MONTH = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    def self.prior_year_period(date, options = {:format => '%b %Y'})
      result = []
      date = DateTime.parse String(date)
      current_month = date.month
      current_year = date.year
      last_year = current_year - 1 + Integer((current_month + 1) / MONS_PER_YEAR)
      start_month = (current_month + 1) % MONS_PER_YEAR

      if last_year < current_year
        (start_month..MONS_PER_YEAR).collect { |mon|
          tmp = DateTime.parse "01-#{mon}-#{last_year}"
          result << tmp.strftime(options[:format])
        }
        start_month = 1
      end
      (start_month..current_month).collect { |mon|
        tmp = DateTime.parse "01-#{mon}-#{current_year}"
        result << tmp.strftime(options[:format])
      }

      return result
    end

    def self.get_days_of_month(mon, year)
      result = DAYS_OF_MONTH[mon]
      if mon==2 && (year%400==0 || (year%4==0 && year%100!=0))
        result += 1
      end
      return result
    end

    def self.last_day_of_month(mon, year)
      last_day = self.get_days_of_month(mon, year)
      return DateTime.parse("#{last_day}-#{mon}-#{year}")
    end
  end
end
