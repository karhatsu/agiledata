module WorkDayAwareCalendar
  def holiday?(date)
    weekend?(date) || predefined_holiday(date)
  end

  def date_range(min_date, max_date)
    return [] unless min_date && max_date
    (min_date..max_date).select {|date| !holiday?(date)}
  end

  def days_between(date1, date2)
    raise "#{date2} is smaller than #{date1}" if date2.to_date < date1.to_date
    date = date1.to_date
    end_date = date2.to_date
    days = 0
    while date < end_date
      days = days + 1 unless holiday? date
      date = date + 1
    end
    days
  end

  def latest_work_day(nth=0)
    date = Date.today
    n = nth
    while holiday?(date) || n > 0
      n -= 1 unless holiday?(date)
      date = date - 1
    end
    date
  end

  private

  def weekend?(date)
    [0, 6].include? date.wday
  end

  def predefined_holiday(date)
    holidays.map {|holiday| holiday.date}.include?(date)
  end
end