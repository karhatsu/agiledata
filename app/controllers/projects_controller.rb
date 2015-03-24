class ProjectsController < ApplicationController
  before_action :set_task_count, only: :show

  def index
    @project = Project.new
  end

  def create
    @project = Project.new(project_attributes)
    if @project.save
      redirect_to project_path(@project, initial: true)
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

  def set_task_count
    if params[:task_count].to_i > 0
      @task_count = params[:task_count].to_i
      cookies[:task_count] = @task_count
    elsif cookies[:task_count].to_i > 0
      @task_count = cookies[:task_count].to_i
    else
      @task_count = 10
    end
  end

  def project_attributes
    params.require(:project).permit([:name])
  end
end