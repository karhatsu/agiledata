class ProjectsController < ApplicationController
  def index
    redirect_to project_path(Project.last) if Project.count > 0
  end

  def show
    @project = Project.find_by_key(params[:id])
    @tasks = @project.tasks
  end
end