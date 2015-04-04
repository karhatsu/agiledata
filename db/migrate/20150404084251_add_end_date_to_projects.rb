class AddEndDateToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :end_date, :date
  end
end
