def expect_task_table_to_have_count(task_count)
  expect(find(:xpath, "//table[@id='data-table']/tbody/tr[#{task_count}]/td[1]")).to have_content(task_count)
end

def expect_task_table_row(task_no, lead_time, task_name, css_class)
  expect(find(:xpath, "//table[@id='data-table']/tbody/tr[#{task_no}]/td[1]")).to have_content(task_no)
  expect(find(:xpath, "//table[@id='data-table']/tbody/tr[#{task_no}]")).to have_content(lead_time)
  expect(page).to have_xpath("//table[@id='data-table']/tbody/tr[#{task_no}]//td[@class='#{css_class}' and @title='#{task_name}']")
end

def expect_task_table_last_date(date)
  expect(find(:xpath, "//table[@id='data-table']/thead/tr[3]/td[last()]")).to have_content(date.strftime('%d.%m'))
end