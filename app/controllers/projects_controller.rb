class ProjectsController < ApplicationController
  def index
  end

  def show
    @project = Project.find_by_key(params[:id])
    @tasks = @project.tasks
  end
end