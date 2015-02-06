class Task < ActiveRecord::Base
  include WeekendHelper

  belongs_to :project

  def work_days_count
    max_date = end_date || Date.today
    count = 0
    date = start_date
    while date <= max_date
      count = count + 1 unless weekend?(date)
      date = date + 1
    end
    count
  end
end
