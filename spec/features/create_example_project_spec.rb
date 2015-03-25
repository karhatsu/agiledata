require 'rails_helper'

feature 'Create example project' do
  scenario 'Example project is created' do
    visit '/'
    click_button 'Create an example project'
    expect(page).to have_css('.example_project_info')
    expect_project_to_have_example_tasks
  end

  private

  def expect_project_to_have_example_tasks
    task_count = ExampleProject.task_count
    expect(find(:xpath, "//tbody/tr[#{task_count}]/td[1]")).to have_content(task_count)
  end
end