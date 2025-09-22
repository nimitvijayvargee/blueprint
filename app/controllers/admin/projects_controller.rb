class Admin::ProjectsController < Admin::ApplicationController
  def index
    @q = params[:q].to_s.strip

    projects = Project.includes(:user)
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
  end
end
