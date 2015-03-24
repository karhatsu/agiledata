class AddExampleToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :example, :boolean, default: false
  end
end
