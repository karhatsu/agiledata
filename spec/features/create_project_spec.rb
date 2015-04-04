require 'feature_helper'

feature 'Create project' do
  background do
    visit '/'
  end

  scenario 'Successful project and task creation' do
    fill_in 'project_name', with: 'My project'
    click_button 'Start!'
    expect_title_to_contain 'My project'
    expect(find('.project_url')).to have_content(project_url(Project.last))
    expect(page).not_to have_css('#data-table')

    click_link 'Start by adding the first task'
    submit_new_task_form 'My first task', Project.last.latest_work_day
    expect(page).not_to have_css('.project_url')
    expect_task_table_to_have_count 1

    click_link 'New task'
    submit_new_task_form 'My second task', Project.last.latest_work_day
    expect_task_table_to_have_count 2
  end

  scenario 'No name given for the project' do
    click_button 'Start!'
    expect_form_error "Project name can't be blank"
  end

  def submit_new_task_form(name, start_date)
    fill_in 'Name', with: name
    select start_date.year, from: 'task_start_date_1i'
    select start_date.strftime('%B'), from: 'task_start_date_2i'
    select start_date.day, from: 'task_start_date_3i'
    click_button 'Save'
  end
end
