class Admin::ProjectsController < Admin::ApplicationController
  skip_before_action :require_admin!, only: [ :index, :show ]
  before_action :require_reviewer_perms!, only: [ :index, :show ]

  def index
    @q = params[:q].to_s.strip

    projects = Project.includes(:user)
                      .where(is_deleted: false)
                      .order(created_at: :desc)

    if @q.present?
      like = "%#{@q}%"
      projects = projects.joins(:user).where(
        "projects.id::text ILIKE :q OR projects.title ILIKE :q OR users.username ILIKE :q OR users.email ILIKE :q",
        q: like
      )
    end

    @pagy, @projects = pagy(projects, items: 20)
  end

  def show
    @project = Project.find(params[:id])
    not_found unless @project
  end

  def delete
    @project = Project.find(params[:id])
    not_found unless @project

    @project.update!(is_deleted: true)
    redirect_to admin_projects_path, notice: "Project soft deleted."
  end

  def revive
    @project = Project.find(params[:id])
    not_found unless @project

    @project.update!(is_deleted: false)
    redirect_to admin_project_path(@project), notice: "Project revived."
  end

  private

  def require_reviewer_perms!
    unless current_user&.reviewer_perms?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
