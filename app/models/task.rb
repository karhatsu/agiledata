class Task < ActiveRecord::Base
  include WorkDayAwareCalendar

  belongs_to :project

  validates :start_date, presence: true
  validate :start_date_not_holiday
  validate :end_date_not_holiday
  validate :start_date_not_in_future
  validate :end_date_not_in_future
  validate :end_date_not_before_start_date

  delegate :holidays, to: :project

  def self.finished
    where 'end_date is not null'
  end

  def work_days_count
    max_date = end_date || Date.today
    count = 0
    date = start_date
    while date <= max_date
      count = count + 1 unless holiday?(date)
      date = date + 1
    end
    count
  end

  def dates
    max_date = end_date || project.end_date
    date_range start_date, max_date
  end

  def finished?
    end_date
  end

  private
  def start_date_not_holiday
    errors.add :start_date, "(#{start_date}) cannot be holiday day" if start_date && holiday?(start_date)
  end

  def end_date_not_holiday
    errors.add :end_date, "(#{end_date}) cannot be holiday day" if end_date && holiday?(end_date)
  end

  def start_date_not_in_future
    errors.add :start_date, "(#{start_date}) cannot be in future" if start_date && start_date > Date.today
  end

  def end_date_not_in_future
    errors.add :end_date, "(#{end_date}) cannot be in future" if end_date && end_date > Date.today
  end

  def end_date_not_before_start_date
    errors.add :end_date, "(#{end_date}) cannot be before start date (#{start_date})" if start_date && end_date && end_date < start_date
  end
end
