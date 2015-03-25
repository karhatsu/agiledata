def expect_form_error(error_message)
  expect(find('.form_errors')).to have_content(error_message)
end