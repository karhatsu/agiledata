require 'rails_helper'

feature 'Create project' do
  background do
    visit '/'
  end

  scenario 'Successful project creation' do
    fill_in 'project_name', with: 'My project'
    click_button 'Start!'
    expect(page).to have_content('My project')
    expect(find('.project_url')).to have_content(project_url(Project.last))
  end

  scenario 'No name given for the project' do
    click_button 'Start!'
    expect(find('.form_errors')).to have_content("Project name can't be blank")
  end
end
