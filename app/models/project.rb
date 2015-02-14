class Project < ActiveRecord::Base
  include Calculator, WeekendAwareCalendar, Statistics, Forecasts

  has_many :tasks, -> { order(:start_date, :end_date) }
  has_many :finished_tasks, -> { finished }, class_name: Task

  validates :name, presence: true

  def min_date
    tasks.minimum('start_date')
  end

  def max_date
    return Date.yesterday if Date.today.wday == 6
    return Date.yesterday.yesterday if Date.today.wday == 0
    Date.today
  end

  def dates
    date_range min_date, max_date
  end
end
