class ProjectsController < ApplicationController
  def index
    redirect_to project_path(Project.last)
  end

  def show
    @project = Project.find(params[:id])
    @tasks = @project.tasks
  end
end