module Forecasts
  def throughput_forecast_for(task_count, last_weeks=nil)
    avg = avg_throughput last_weeks
    return nil if avg.to_f == 0
    task_count.to_f / avg * 5
  end

  def lead_time_wip_forecast_for(tasks_count, last_tasks=nil, last_days=nil)
    lt = avg_lead_time last_tasks
    wip = avg_wip last_days
    return nil if lt.nil? || wip.to_f == 0
    tasks_count.to_f * lt / wip
  end

  def takt_time_forecast_for(task_count, last_weeks=nil)
    tt = avg_takt_time last_weeks
    return nil unless tt
    task_count.to_f * tt
  end
end