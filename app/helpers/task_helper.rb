module TaskHelper
  def cell_edit_link(project, task, text)
    text_with_span = "<span class='cell_link'>#{text}<span class='cell_task_name' style='display: none;'> #{task.name}</span></span>"
    raw link_to(raw(text_with_span), edit_project_task_path(project, task))
  end

  def unfinished_css_class(work_days_count)
    return 'length_ok' if work_days_count <= 3
    return 'length_worrying' if work_days_count <= 6
    'length_bad'
  end
end