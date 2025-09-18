class ProjectsController < ApplicationController
  allow_unauthenticated_access only: %i[explore show]

  def index
    @projects = current_user.projects.with_attached_banner
  end

  def explore; end

  def show
    @project = Project.find_by(id: params[:id])
    not_found unless @project
  end

  def new
    @project = current_user.projects.build
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save
      redirect_to projects_path, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def project_params
    params.require(:project).permit(
      :title,
      :description,
      :repo_link,
      :demo_link,
      :readme_link,
      :project_type,
      :banner
    )
  end
end
