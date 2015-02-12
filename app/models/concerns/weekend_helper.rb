module WeekendHelper
  def weekend?(date)
    [0, 6].include? date.wday
  end

  def date_range(min_date, max_date)
    return [] unless min_date && max_date
    (min_date..max_date).select {|date| !weekend?(date)}
  end
end