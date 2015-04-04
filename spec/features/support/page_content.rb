def expect_title_to_contain(text)
  expect(page).to have_content(text)
end