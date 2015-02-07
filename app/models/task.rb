class Task < ActiveRecord::Base
  include WeekendHelper

  belongs_to :project

  validates :start_date, presence: true
  validate :start_date_not_weekend
  validate :end_date_not_weekend
  validate :end_date_not_in_future

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

  private
  def start_date_not_weekend
    errors.add :start_date, 'cannot be weekend day' if start_date && weekend?(start_date)
  end

  def end_date_not_weekend
    errors.add :end_date, 'cannot be weekend day' if end_date && weekend?(end_date)
  end

  def end_date_not_in_future
    errors.add :end_date, 'cannot be in future' if end_date && end_date > Date.today
  end
end
