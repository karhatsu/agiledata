module TaskHelper
  def cell_edit_link(project, task, text)
    text_with_span = "<span class='cell_link'>#{text}</span>"
    raw link_to(raw(text_with_span), edit_project_task_path(project, task))
  end
end