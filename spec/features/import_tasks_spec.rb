require 'rails_helper'

feature 'Import multiple tasks' do
  given(:project) { create :project }

  background do
    create :task, project: project
    visit project_path(project)
    expect_task_table_to_have_count 1
  end

  scenario 'Import data is valid' do
    click_link 'New task'
    click_link 'Import multiple tasks at once'
    fill_in 'data', with: "2015-03-03,2015-03-05,Finished task\n2015-03-10,,Unfinished task"
    click_button 'Import data'
    expect_task_table_to_have_count 3
  end

  scenario 'Data contains weekend dates' do
    click_link 'New task'
    click_link 'Import multiple tasks at once'
    fill_in 'data', with: "2015-03-03,2015-03-05,Finished task\n2015-03-07,2015-03-09,Saturday task"
    click_button 'Import data'
    expect_form_error 'Start date (2015-03-07) cannot be holiday day'
    visit project_path(project)
    expect_task_table_to_have_count 1
  end
end
