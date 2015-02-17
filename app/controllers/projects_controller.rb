class ProjectsController < ApplicationController
  def index
  end

  def show
    @project = Project.find_by_key(params[:id])
    return redirect_to(projects_path) unless @project
    @tasks = @project.tasks
  end
end