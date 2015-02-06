class Project < ActiveRecord::Base
  include WeekendHelper

  has_many :tasks

  def days
    days = []
    max = max_date
    date = min_date
    while date <= max
      days << date unless weekend?(date)
      date = date + 1
    end
    days
  end

  def wip_per_day
    hash = Hash.new
    tasks.each do |task|
      date = task.start_date
      max = task.end_date || Date.today
      while date <= max
        if hash[date].nil?
          hash[date] = 1
        else
          hash[date] = hash[date] + 1
        end
        date = date + 1
      end
    end
    hash
  end

  def min_date
    tasks.minimum('start_date')
  end

  def max_date
    Date.today
  end
end
