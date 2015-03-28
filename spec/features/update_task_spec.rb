require 'feature_helper'

feature 'Update task' do
  let(:project) { create :project }
  let(:task) { create :task, project: project, name: 'Initial task name' }

  background do
    task
    visit project_path(project)
  end

  scenario 'Update task name' do
    find(:xpath, '//tbody//td/a').click
    expect(find_field('task_name').value).to eql('Initial task name')
    fill_in 'Name', with: 'New task name'
    click_button 'Update'
    expect(page).to have_xpath("//tbody//td[@title='New task name']")
  end
end
