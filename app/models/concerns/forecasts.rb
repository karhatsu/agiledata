module Forecasts
  def throughput_forecast_for(task_count, last_weeks=nil)
    avg = avg_throughput last_weeks
    return nil if avg.to_f == 0
    task_count.to_f / avg * 5
  end

  def lead_time_wip_forecast_for(tasks_count, last_tasks=nil, last_days=nil)
    lt = avg_lead_time last_tasks
    wip = avg_wip last_days
    return nil if wip.to_i == 0
    tasks_count.to_f * lt / wip
  end
end