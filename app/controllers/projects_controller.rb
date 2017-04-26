class ProjectsController < ApplicationController
  before_action :set_task_count, only: :show

  def index
    @project = Project.new
  end

  def create
    @project = Project.new(new_project_attributes)
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

  def edit
    @project = Project.find_by_key(params[:id])
  end

  def update
    @project = Project.find_by_key(params[:id])
    if @project.update(existing_project_attributes)
      redirect_to project_path(@project)
    else
      render :edit
    end
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

  def new_project_attributes
    params.require(:project).permit([:name])
  end

  def existing_project_attributes
    params.require(:project).permit([:name, :end_date, :weekends, holidays_attributes: [:date, :_destroy, :id]])
  end
end