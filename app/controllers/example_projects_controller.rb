class ExampleProjectsController < ApplicationController
  def create
    project = ExampleProject.create!
    redirect_to project_path(project)
  end
end