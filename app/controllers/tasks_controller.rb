class TasksController < ApplicationController
  def new
    @task = project.tasks.build
  end

  def create
    @task = project.tasks.build task_attributes
    if @task.save
      redirect_to project_path(project)
    else
      render :new
    end
  end

  def edit
    @task = project.tasks.find params[:id]
  end

  def update
    @task = project.tasks.find params[:id]
    if @task.update(task_attributes)
      redirect_to project_path(project)
    else
      render :edit
    end
  end

  def destroy
    @task = project.tasks.find params[:id]
    @task.destroy
    redirect_to project_path(project)
  end

  private

  def project
    @project ||= Project.find_by_key params[:project_id]
  end

  def task_attributes
    params.require(:task).permit([:start_date, :end_date, :name])
  end
end