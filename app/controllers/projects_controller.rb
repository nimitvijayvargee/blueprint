class ProjectsController < ApplicationController
  allow_unauthenticated_access only: %i[explore show]

  def index
    @projects = current_user.projects
      .order_by_recent_journal
      .includes(:banner_attachment)
  end

  def explore; end

  def show
    @project = Project.find_by(id: params[:id])
    not_found unless @project
  end

  def ship
    @project = current_user.projects.find_by(id: params[:id])
    not_found unless @project

    repo_linked = @project.repo_link.present?
    desc_ok = @project.description.to_s.strip.length >= 50
    journal_ok = @project.journal_entries.exists?

    @checks = [
      { msg: "GitHub repo linked", met: repo_linked },
      { key: "bom", msg: "Bill of materials (bom.csv) present", met: nil },
      { msg: "Description is at least 50 characters", met: desc_ok },
      { msg: "At least one journal entry", met: journal_ok }
    ]

    @base_ok = repo_linked && desc_ok && journal_ok
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

  def destroy
    @project = current_user.projects.find_by(id: params[:id])
    not_found and return unless @project

    @project.destroy
    redirect_to projects_path, notice: "Project deleted."
  end

  def check_github_repo
    unless current_user.github_user?
      render json: { ok: false, error: "GitHub account not linked (Check the tasks panel)" }, status: :unprocessable_entity
      return
    end

    repo = params[:repo].to_s.strip

    parsed_repo = Project.parse_repo(repo)
    unless parsed_repo
      render json: { ok: false, error: "Invalid GitHub repo" }, status: :unprocessable_entity
      return
    end
    org = parsed_repo[:org] || current_user.github_username
    repo_name = parsed_repo[:repo_name]

    project_param_id = params[:project_id].presence || params[:id].presence
    if project_param_id.present?
      project = current_user.projects.find_by(id: project_param_id)
      unless project
        render json: { ok: false, error: "Not authorized for this project" }, status: :forbidden
        return
      end
    end

    render json: current_user.check_github_repo(org, repo_name, project_id: project_param_id)
  rescue StandardError => e
    render json: { ok: false, error: e.message }, status: :unprocessable_entity
  end

  def check_bom
    unless current_user.present?
      render json: { ok: false, error: "Not authenticated" }, status: :unauthorized
      return
    end

    project_param_id = params[:project_id].presence || params[:id].presence
    project = current_user.projects.find_by(id: project_param_id)
    unless project
      render json: { ok: false, error: "Not authorized for this project" }, status: :forbidden
      return
    end

    unless project.repo_link.present?
      render json: { ok: false, error: "No linked GitHub repo" }, status: :unprocessable_entity
      return
    end

    exists = project.bom_file_exists?
    render json: { ok: true, exists: exists, url: project.bom_file_url }
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
      :banner,
      :is_shipped
    )
  end
end
