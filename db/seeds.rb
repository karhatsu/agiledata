def work_day(date)
  case date.wday
    when 0
      date - 2.days
    when 6
      date - 1.day
    else
      date
  end
end

project = Project.create!(name: 'Agile project, LOL')
project.tasks << Task.new(start_date: work_day(12.days.ago), end_date: work_day(8.days.ago))
project.tasks << Task.new(start_date: work_day(10.days.ago), end_date: work_day(3.days.ago))
project.tasks << Task.new(start_date: work_day(15.days.ago), end_date: work_day(10.days.ago))
project.tasks << Task.new(start_date: work_day(12.days.ago), end_date: work_day(10.days.ago))
project.tasks << Task.new(start_date: work_day(10.days.ago), end_date: work_day(6.days.ago))
project.tasks << Task.new(start_date: work_day(13.days.ago), end_date: work_day(10.days.ago))
project.tasks << Task.new(start_date: work_day(5.days.ago))
project.tasks << Task.new(start_date: work_day(2.days.ago))
