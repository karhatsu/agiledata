require 'feature_helper'

feature 'Show tasks table' do
  let(:project) { create :project }

  background do
    create_task 'Task 2', 16, 12
    create_task 'Unfinished task, ok', 2
    create_task 'Task 1', 17, 14  # started first, should be first
    create_task 'Unfinished task, worrying', 5
    create_task 'Unfinished task, bad', 6
  end

  scenario 'Two finished tasks, three unfinished tasks with different speculated lead times' do
    visit project_path(project)
    expect_task_table_to_have_count 3
    expect_task_table_row 1, 4, 'Task 1', 'active'
    expect_task_table_row 2, 5, 'Task 2', 'active'
    expect_task_table_row 3, '7?', 'Unfinished task, bad', 'length_bad unfinished'
    expect_task_table_row 4, '6?', 'Unfinished task, worrying', 'length_worrying unfinished'
    expect_task_table_row 5, '3?', 'Unfinished task, ok', 'length_ok unfinished'
  end

  def create_task(name, start_day_from_now, end_day_from_now=nil)
    end_date = project.latest_work_day(end_day_from_now) if end_day_from_now
    create :task, project: project, name: name,
           start_date: project.latest_work_day(start_day_from_now), end_date: end_date
  end
end