def expect_task_table_to_have_count(task_count)
  expect(find(:xpath, "//tbody/tr[#{task_count}]/td[1]")).to have_content(task_count)
end
