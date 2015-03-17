class ProjectsController < ApplicationController
  def index
    @project = Project.new
  end

  def create
    @project = Project.new(project_attributes)
    if @project.save
      redirect_to project_path(@project)
    else
      render :index
    end
  end

  def show
    @project = Project.find_by_key(params[:id])
    return redirect_to(projects_path) unless @project
    @tasks = @project.tasks
  end

  private

  def project_attributes
    params.require(:project).permit([:name])
  end
end