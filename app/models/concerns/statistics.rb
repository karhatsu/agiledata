module Statistics
  def wip_per_day
    hash = dates_hash 0
    tasks.each do |task|
      dates = task.dates
      finished = task.finished?
      dates.each_with_index do |date, i|
        hash[date] = hash[date] + wip_increase_for_day(dates, i, finished)
      end
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
    finished_tasks.inject(hash) do |hash, task|
      week = task.end_date.beginning_of_week
      hash[week] = hash[week] + 1
      hash
    end
  end

  def avg_throughput(prev_weeks=nil, end_date=nil)
    chosen_tasks = finished_tasks
    return nil if chosen_tasks.empty?
    dates = dates end_date
    weeks = dates.size.to_f / 5
    if prev_weeks && dates.size.to_f/5 > prev_weeks
      min_date = dates[dates.size - 5*prev_weeks]
      max_date = dates[dates.size - 1]
      chosen_tasks = chosen_tasks.select {|task| task.end_date >= min_date && task.end_date <= max_date}
      weeks = prev_weeks
    end
    chosen_tasks.size.to_f / weeks
  end

  def avg_lead_time(last=nil)
    chosen_tasks = finished_tasks
    chosen_tasks = chosen_tasks.last(last) if last.to_i > 0
    return nil if chosen_tasks.empty?
    average lead_times(chosen_tasks)
  end

  def avg_days_per_task(last_tasks=nil, last_days=nil)
    wip = avg_wip(last_days)
    return nil unless wip
    lead_time = avg_lead_time(last_tasks)
    return nil unless lead_time
    lead_time / wip
  end

  def avg_takt_time(prev_weeks=nil)
    takt_times = []
    prev_task = nil
    min_date = max_date - 7 * prev_weeks if prev_weeks
    finished_tasks.each do |task|
      if prev_weeks.nil? || task.end_date > min_date
        takt_times << days_between(prev_task.end_date, task.end_date) if prev_task
      end
      prev_task = task
    end
    average takt_times
  end

  private

  def dates_hash(default_value=nil)
    hash = Hash.new
    dates.each {|day| hash[day] = default_value}
    hash
  end

  def wip_increase_for_day(dates, date_index, finished)
    if dates.length == 1
      1
    elsif first_or_last dates, date_index, finished
      0.5
    else
      1
    end
  end

  def first_or_last(dates, date_index, finished)
    date_index == 0 || (finished && date_index + 1 == dates.length)
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