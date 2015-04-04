require 'feature_helper'

feature 'Edit project' do
  let(:project) { create :project }

  background do
    visit project_path(project)
  end

  scenario 'Edit project' do
    click_link 'Edit project'
    fill_in 'Project name', with: ''
    click_button 'Save'
    expect_form_error "Project name can't be blank"
    fill_in 'Project name', with: 'New project name'
    click_button 'Save'
    expect(current_path).to eql(project_path(project))
    expect_title_to_contain 'New project name'
  end
end