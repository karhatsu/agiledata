class ProjectsController < ApplicationController
  def index
    if Project.count == 0
      return render text: 'No projects'
    end
    redirect_to project_path(Project.last)
  end

  def show
    @project = Project.find(params[:id])
    @tasks = @project.tasks
  end
end