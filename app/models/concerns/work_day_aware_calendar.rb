module WorkDayAwareCalendar
  def weekend?(date)
    [0, 6].include? date.wday
  end

  def date_range(min_date, max_date)
    return [] unless min_date && max_date
    (min_date..max_date).select {|date| !weekend?(date)}
  end

  def days_between(date1, date2)
    raise "#{date2} is smaller than #{date1}" if date2.to_date < date1.to_date
    date = date1.to_date
    end_date = date2.to_date
    days = 0
    while date < end_date
      days = days + 1 unless weekend? date
      date = date + 1
    end
    days
  end
end