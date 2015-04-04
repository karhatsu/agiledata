def select_task_start_date(date)
  select date.year, from: 'task_start_date_1i'
  select date.strftime('%B'), from: 'task_start_date_2i'
  select date.day, from: 'task_start_date_3i'
end

def select_project_end_date(date)
  select date.year, from: 'project_end_date_1i'
  select date.strftime('%B'), from: 'project_end_date_2i'
  select date.day, from: 'project_end_date_3i'
end
