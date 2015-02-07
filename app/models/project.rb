class Project < ActiveRecord::Base
  include WeekendHelper

  has_many :tasks

  validates :name, presence: true

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

  def wip_per_day
    hash = Hash.new
    tasks.each do |task|
      date = task.start_date
      max = task.end_date || Date.today
      while date <= max
        if hash[date].nil?
          hash[date] = 1
        else
          hash[date] = hash[date] + 1
        end
        date = date + 1
      end
    end
    hash
  end

  def weekly_throughput
    hash = Hash.new
    tasks.each do |task|
      next unless task.end_date
      week = task.end_date.strftime('%W').to_i
      if hash[week].nil?
        hash[week] = 1
      else
        hash[week] = hash[week] + 1
      end
    end
    hash
  end

  def avg_lead_time
    times = lead_times
    return nil if times.empty?
    times.reduce(:+).to_f / times.size
  end

  def lead_times
    tasks.select {|task| task.end_date}.map {|task| task.work_days_count}
  end

  def min_date
    tasks.minimum('start_date')
  end

  def max_date
    Date.today
  end
end
