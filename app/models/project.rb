class Project < ActiveRecord::Base
  include WeekendHelper

  has_many :tasks

  def days
    days = []
    max = max_date
    date = min_date
    while date <= max
      days << date unless weekend?(date)
      date = date + 1
    end
    days
  end

  def min_date
    tasks.minimum('start_date')
  end

  def max_date
    Date.today
  end
end
