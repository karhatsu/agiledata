class Task < ActiveRecord::Base
  belongs_to :project

  def days_count
    (end_date - start_date + 1).to_i
  end

  def current_days_count
    return days_count if end_date
    (Date.today - start_date + 1).to_i
  end
end
