class AddKeyToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :key, :string
    add_index :projects, :key
    Project.all.each do |project|
      project.send :generate_key
      project.save!
    end
  end

  def down
    remove_column :projects, :key
  end
end
