require 'feature_helper'

feature 'Create example project' do
  scenario 'Example project is created' do
    visit '/'
    click_button 'Create an example project'
    expect(page).to have_css('.example_project_info')
    expect_task_table_to_have_count ExampleProject.task_count
  end
end