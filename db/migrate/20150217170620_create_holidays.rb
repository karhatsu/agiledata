class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.references :project, index: true
      t.date :date

      t.timestamps null: false
    end
    add_foreign_key :holidays, :projects
  end
end
