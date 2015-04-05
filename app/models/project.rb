class Project < ActiveRecord::Base
  include Calculator, WorkDayAwareCalendar, Statistics, Forecasts

  has_many :holidays, -> { order(:date) }
  has_many :tasks, -> { order(:start_date, :end_date) }
  has_many :finished_tasks, -> { finished.order(:end_date) }, class_name: Task

  validates :name, presence: true

  before_create :generate_key

  accepts_nested_attributes_for :holidays

  def to_param
    key
  end

  def min_date
    tasks.minimum('start_date')
  end

  def max_date
    latest_work_day_for(end_date || Date.today)
  end

  def dates
    date_range min_date, max_date
  end

  def create_task(name, start_date=Date.today)
    tasks << Task.new(name: name, start_date: start_date)
  end

  def import_tasks(data)
    errors = []
    tasks = []
    data.split("\n").each do |row|
      cols = row.split(',')
      task = Task.new project: self, start_date: cols[0], end_date: cols[1], name: build_task_name(cols)
      if task.valid?
        tasks << task
      else
        errors << task.errors.full_messages.join(', ')
      end
    end
    return errors unless errors.empty?
    tasks.each {|task| task.save!}
    []
  end

  private

  def generate_key
    self.key = (('a'..'z').to_a+('A'..'Z').to_a).shuffle[0,30].join
  end

  def build_task_name(cols)
    return cols[2] if cols.length == 2
    cols[2,cols.length].join(',')
  end
end
