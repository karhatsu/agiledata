require 'rails_helper'

feature 'Create project' do
  background do
    visit '/'
  end

  scenario 'Successful project and task creation' do
    fill_in 'project_name', with: 'My project'
    click_button 'Start!'
    expect(page).to have_content('My project')
    expect(find('.project_url')).to have_content(project_url(Project.last))

    click_link 'Start by adding the first task'
    fill_in 'Name', with: 'My first task'
    click_button 'Save'
    expect(page).not_to have_css('.project_url')
    expect_task_table_to_have_count 1

    click_link 'New task'
    fill_in 'Name', with: 'My second task'
    click_button 'Save'
    expect_task_table_to_have_count 2
  end

  scenario 'No name given for the project' do
    click_button 'Start!'
    expect_form_error "Project name can't be blank"
  end
end
