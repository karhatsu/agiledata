class TaskImportsController < ApplicationController
  def new
    @errors = []
    project
  end

  def create
    errors = project.import_tasks(params[:data])
    return redirect_to project_path(project) if errors.empty?
    @errors = errors
    render :new
  end

  private

  def project
    @project = Project.find_by_key(params[:project_id])
  end
end