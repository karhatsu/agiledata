class Project < ActiveRecord::Base
  include WeekendHelper

  has_many :tasks, -> { order(:start_date, :end_date) }

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

  def days_hash(default_value=nil)
    hash = Hash.new
    days.each {|day| hash[day] = default_value}
    hash
  end

  def week_hash(default_value=nil)
    hash = Hash.new
    min_week = min_date.strftime('%W').to_i
    max_week = max_date.strftime('%W').to_i
    week = min_week
    while week <= max_week
      hash[week] = default_value
      week = week + 1
    end
    hash
  end

  def wip_per_day
    hash = days_hash 0
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

  def avg_wip(last_days=nil)
    wips = wip_per_day.values
    wips = wips.last(last_days) if last_days
    wips.reduce(:+).to_f / wips.size
  end

  def weekly_throughput
    hash = week_hash(0)
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

  def avg_throughput(last=nil)
    throughputs = weekly_throughput.values
    throughputs = throughputs.last(last) if last
    throughputs.reduce(:+).to_f / throughputs.size
  end

  def avg_lead_time(last=nil)
    chosen_tasks = tasks.select {|task| task.end_date}
    chosen_tasks = chosen_tasks.last(last) if last.to_i > 0
    times = lead_times(chosen_tasks)
    return nil if times.empty?
    times.reduce(:+).to_f / times.size
  end

  def lead_times(tasks)
    tasks.map {|task| task.work_days_count}
  end

  def min_date
    tasks.minimum('start_date')
  end

  def max_date
    Date.today
  end

  def avg_days_per_task(last=nil, last_days=nil)
    wip = avg_wip(last_days)
    avg_lead_time(last) / wip
  end

  def throughput_forecast_for(tasks_count, last_weeks=nil)
    avg = avg_throughput last_weeks
    return nil if avg.to_f == 0
    tasks_count.to_f / avg * 5
  end

  def lead_time_wip_forecast_for(tasks_count, last_tasks=nil, last_days=nil)
    lt = avg_lead_time last_tasks
    wip = avg_wip last_days
    return nil if wip.to_i == 0
    tasks_count.to_f * lt / wip
  end
end
