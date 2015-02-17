class Project < ActiveRecord::Base
  include Calculator, WorkDayAwareCalendar, Statistics, Forecasts

  has_many :holidays
  has_many :tasks, -> { order(:start_date, :end_date) }
  has_many :finished_tasks, -> { finished.order(:end_date) }, class_name: Task

  validates :name, presence: true

  before_create :generate_key

  def to_param
    key
  end

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

  private

  def generate_key
    self.key = (('a'..'z').to_a+('A'..'Z').to_a).shuffle[0,30].join
  end
end
