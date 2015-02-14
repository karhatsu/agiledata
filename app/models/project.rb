class Project < ActiveRecord::Base
  include Calculator, WeekendAwareCalendar

  has_many :tasks, -> { order(:start_date, :end_date) }

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

  def wip_per_day
    hash = dates_hash 0
    tasks.each do |task|
      task.dates.inject(hash) { |hash, date| hash[date] = hash[date] + 1; hash }
    end
    hash
  end

  def avg_wip(last_days=nil)
    daily_wips = wip_per_day.values
    daily_wips = daily_wips.last(last_days) if last_days
    average daily_wips
  end

  def weekly_throughput
    hash = week_hash(0)
    tasks.select {|task| task.end_date}.inject(hash) do |hash, task|
      week = task.end_date.beginning_of_week
      hash[week] = hash[week] + 1
      hash
    end
  end

  def avg_throughput(prev_weeks=nil)
    chosen_tasks = tasks.select {|task| task.end_date}
    weeks = dates.size.to_f / 5
    if prev_weeks && dates.size.to_f/5 > prev_weeks
      min_date = dates[dates.size - 1 - 5*prev_weeks]
      max_date = dates[dates.size - 1]
      chosen_tasks = chosen_tasks.select {|task| task.end_date >= min_date && task.end_date <= max_date}
      weeks = prev_weeks
    end
    chosen_tasks.size.to_f / weeks
  end

  def avg_lead_time(last=nil)
    chosen_tasks = tasks.select {|task| task.end_date}
    chosen_tasks = chosen_tasks.last(last) if last.to_i > 0
    times = lead_times(chosen_tasks)
    return nil if times.empty?
    times.reduce(:+).to_f / times.size
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

  private

  def dates_hash(default_value=nil)
    hash = Hash.new
    dates.each {|day| hash[day] = default_value}
    hash
  end

  def week_hash(default_value=nil)
    hash = Hash.new
    return hash if tasks.empty?
    min_week = min_date.beginning_of_week
    max_week = max_date.beginning_of_week
    week = min_week
    while week <= max_week
      hash[week] = default_value
      week = week + 7
    end
    hash
  end

  def lead_times(tasks)
    tasks.map {|task| task.work_days_count}
  end
end
