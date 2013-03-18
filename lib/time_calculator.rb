class TimeCalculator
  MONS_PER_YEAR = 12
  DAYS_OF_MONTH = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def self.prior_year_period(date, options = {:format => '%b %Y'})
    result = []
    date = DateTime.parse String(date)
    current_month = date.month
    current_year = date.year

    start_date = (date - MONS_PER_YEAR.months)
    last_year = start_date.year
    start_month = start_date.month

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