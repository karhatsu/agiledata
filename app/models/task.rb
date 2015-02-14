class Task < ActiveRecord::Base
  include WeekendAwareCalendar

  belongs_to :project

  validates :start_date, presence: true
  validate :start_date_not_weekend
  validate :end_date_not_weekend
  validate :start_date_not_in_future
  validate :end_date_not_in_future
  validate :end_date_not_before_start_date

  def self.finished
    where 'end_date is not null'
  end

  def work_days_count
    return nil unless end_date
    max_date = end_date
    count = 0
    date = start_date
    while date <= max_date
      count = count + 1 unless weekend?(date)
      date = date + 1
    end
    count
  end

  def dates
    max_date = end_date || Date.today
    date_range start_date, max_date
  end

  private
  def start_date_not_weekend
    errors.add :start_date, 'cannot be weekend day' if start_date && weekend?(start_date)
  end

  def end_date_not_weekend
    errors.add :end_date, 'cannot be weekend day' if end_date && weekend?(end_date)
  end

  def start_date_not_in_future
    errors.add :start_date, 'cannot be in future' if start_date && start_date > Date.today
  end

  def end_date_not_in_future
    errors.add :end_date, 'cannot be in future' if end_date && end_date > Date.today
  end

  def end_date_not_before_start_date
    errors.add :end_date, 'cannot be before start date' if start_date && end_date && end_date < start_date
  end
end
