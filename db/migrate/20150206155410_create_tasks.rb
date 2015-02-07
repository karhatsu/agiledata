class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :project, index: true
      t.date :start_date
      t.date :end_date
      t.string :name

      t.timestamps null: false
    end
    add_foreign_key :tasks, :projects
  end
end
