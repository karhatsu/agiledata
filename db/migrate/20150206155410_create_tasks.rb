class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :project
      t.date :start_date
      t.date :end_date
      t.string :name

      t.timestamps null: false
    end
    add_foreign_key :projects, :projects
  end
end
