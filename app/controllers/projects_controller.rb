class ProjectsController < ApplicationController
  allow_unauthenticated_access only: %i[explore show]

  def index
    @projects = current_user.projects.where(is_deleted: false)
      .order_by_recent_journal
      .includes(:banner_attachment)
  end

  def explore
    @journal_entries = JournalEntry.joins(:project).where(projects: { is_deleted: false }).includes(project: :user).order(created_at: :desc).limit(20)
  end

  def show
    @project = Project.includes(:user).find_by(id: params[:id], is_deleted: false)
    not_found and return unless @project

    ahoy.track("project_view", project_id: @project.id, user_id: current_user&.id)
  end

  def ship
    @project = current_user.projects.find_by(id: params[:id], is_deleted: false)
    not_found and return unless @project

    if !@project.can_ship?
      redirect_to project_path(@project), alert: "Project cannot be shipped."
      return
    end

    repo_linked = @project.repo_link.present?
    desc_ok = @project.description.to_s.strip.length >= 50
    journal_ok = @project.journal_entries.count >= 3
    banner_ok = @project.banner.attached?

    @checks = [
      { msg: "GitHub repo linked", met: repo_linked },
      { key: "bom", msg: "Bill of materials (bom.csv) present", met: nil },
      { key: "readme", msg: "README.md present", met: nil },
      { msg: "Description is at least 50 characters", met: desc_ok },
      { msg: "Project has 3 journal entries", met: journal_ok },
      { msg: "Banner image uploaded", met: banner_ok }
    ]

    @base_ok = repo_linked && desc_ok && journal_ok && banner_ok
  end

  def follow
    @project = Project.where.not(user_id: current_user.id).find_by(id: params[:id], is_deleted: false)
    not_found unless @project

    current_user.follow_project!(@project)
    redirect_to project_path(@project), notice: "Followed #{@project.title}."
  end

  def unfollow
    @project = Project.where.not(user_id: current_user.id).find_by(id: params[:id], is_deleted: false)
    not_found unless @project

    current_user.unfollow_project!(@project)
    redirect_to project_path(@project), notice: "Unfollowed #{@project.title}."
  end

  def new
    @project = current_user.projects.build
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save
      ahoy.track("project_create", project_id: @project.id, user_id: current_user&.id)
      redirect_to projects_path, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @project = current_user.projects.find_by(id: params[:id], is_deleted: false)
    not_found unless @project
    not_found unless @project.can_edit?
  end

  def update
    @project = current_user.projects.find_by(id: params[:id], is_deleted: false)
    not_found and return unless @project
    not_found and return unless @project.can_edit?

    has_ship = params.dig(:project, :ship).present?
    params[:project].delete(:ship) if has_ship

    if params.dig(:project, :ysws) == "none"
      params[:project][:ysws] = nil
    elsif params.dig(:project, :ysws) == "other" && params.dig(:project, :ysws_other).present?
      params[:project][:ysws] = params[:project][:ysws_other]
    end
    params[:project].delete(:ysws_other)

    if params.dig(:project, :needs_funding) == "false" || params.dig(:project, :needs_funding) == false
      params[:project][:tier] = nil
    end

    # Compute print_legion from radio inputs
    if params.dig(:project, :has_3d_print).present? && params.dig(:project, :needs_3d_print_help).present?
      has_3d = params[:project][:has_3d_print] == "yes"
      needs_help = params[:project][:needs_3d_print_help] == "yes"
      params[:project][:print_legion] = (has_3d && needs_help)
    end

    # Validate cart_screenshots if needed
    if has_ship && @project.needs_funding? && !@project.cart_screenshots.attached? && Array(params.dig(:project, :cart_screenshots)).reject(&:blank?).empty?
      @project.errors.add(:cart_screenshots, "are required when requesting funding")
      render :ship, status: :unprocessable_entity and return
    end

    if @project.update(project_params)
      if has_ship
        ahoy.track("project_ship", project_id: @project.id, user_id: current_user&.id)

        if Flipper.enabled?(:new_ship_flow_10_06, current_user)
          current_user.refresh_idv_data!
          @project.ship!

          if current_user.idv_linked?
            redirect_to project_path(@project), notice: "Project shipped."
          else
            render "ship_idv", status: 303
          end
        else
          @project.ship!
          redirect_to project_path(@project), notice: "Project shipped."
        end
      else
        redirect_to project_path(@project), notice: "Project updated."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = current_user.projects.find_by(id: params[:id], is_deleted: false)
    not_found and return unless @project
    not_found and return unless @project.can_edit?

    @project.update!(is_deleted: true)
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

  def check_readme
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

    exists = project.readme_file_exists?
    render json: { ok: true, exists: exists, url: project.readme_file_url }
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
      :tier,
      :ship,
      :ysws,
      :ysws_other,
      :needs_funding,
      :funding_needed_cents,
      :print_legion,
      cart_screenshots: []
    )
  end
end
