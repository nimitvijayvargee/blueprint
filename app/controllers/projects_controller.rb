class ProjectsController < ApplicationController
  allow_unauthenticated_access only: %i[explore show]

  def index
    @projects = current_user.projects.includes(:banner_attachment)
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

  def edit
    @project = current_user.projects.find_by(id: params[:id])
    not_found unless @project
  end

  def update
    @project = current_user.projects.find_by(id: params[:id])
    not_found and return unless @project

    if @project.update(project_params)
      redirect_to project_path(@project), notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def check_github_repo
    unless current_user.github_user?
      render json: { ok: false, error: "GitHub account not linked" }, status: :unprocessable_entity
      return
    end

    repo = params[:repo].to_s.strip

    parsed_repo = Project.parse_repo(repo)
    unless parsed_repo
      render json: { ok: false, error: "Invalid GitHub repo" }, status: :unprocessable_entity
      return
    end
    org = parsed_repo[:org]
    repo_name = parsed_repo[:repo_name]

    render json: current_user.check_github_repo(org, repo_name)
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
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
