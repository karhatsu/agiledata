class Project < ActiveRecord::Base
  has_many :tasks

  def min_date
    tasks.minimum('start_date')
  end

  def max_date
    Date.today
  end
end
