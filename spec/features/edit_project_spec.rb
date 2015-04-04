require 'feature_helper'

feature 'Edit project' do
  let(:project) { create :project }

  scenario 'Edit project name' do
    visit project_path(project)
    click_link 'Edit project'
    fill_in 'Project name', with: ''
    click_button 'Save'
    expect_form_error "Project name can't be blank"
    fill_in 'Project name', with: 'New project name'
    click_button 'Save'
    expect(current_path).to eql(project_path(project))
    expect_title_to_contain 'New project name'
  end

  scenario 'Finish project' do
    project.create_task 'The only task', '2015-03-23'
    visit project_path(project)
    expect_task_table_last_date project.latest_work_day
    click_link 'Edit project'
    end_date = Date.new(2015, 3, 27)
    select_project_end_date end_date
    click_button 'Save'
    expect_task_table_last_date end_date
  end
end