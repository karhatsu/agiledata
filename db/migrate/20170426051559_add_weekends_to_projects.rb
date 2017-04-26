class AddWeekendsToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :weekends, :boolean, default: false, null: false
  end
end
