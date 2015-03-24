class ExampleProject
  def self.create!
    project = Project.create! name: 'Example project', example: true
    20.times do |i|
      start_date = (50-(2*i)).days.ago.to_date
      end_date = start_date + 1 + Random.rand(8)
      create_task project, i, start_date, end_date
    end
    create_task project, 20, 6.days.ago, 3.days.ago
    3.times do |i|
      create_unfinished_task project, i, (7-(2*i)).days.ago
    end
    project.reload
  end

  private

  def self.create_task(project, i, start_date, end_date)
    Task.create! project: project, name: "Example task #{i+1}", start_date: work_day(start_date),
                 end_date: work_day(end_date)
  end

  def self.create_unfinished_task(project, i, start_date)
    Task.create! project: project, name: "Unfinished example task #{i+1}", start_date: work_day(start_date)
  end

  def self.work_day(date)
    case date.wday
      when 0
        date - 2.days
      when 6
        date - 1.day
      else
        date
    end
  end
end