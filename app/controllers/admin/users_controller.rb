class Admin::UsersController < Admin::ApplicationController
  skip_before_action :require_admin!, only: [ :index, :show ]
  before_action :require_reviewer_perms!, only: [ :index, :show ]

  def index
    @q = params[:q].to_s.strip

    users = User.order(created_at: :desc)

    if @q.present?
      like = "%#{@q}%"
      users = users.where(
        "users.id::text ILIKE :q OR users.username ILIKE :q OR users.email ILIKE :q OR users.slack_id ILIKE :q",
        q: like
      )
    end

    @pagy, @users = pagy(users, items: 20)
  end

  def show
    @user = User.find(params[:id])
    not_found unless @user
  end

  def grant_reviewer
    @user = User.find(params[:id])
    @user.update!(role: "reviewer")
    redirect_to admin_user_path(@user), notice: "User granted reviewer role"
  end

  def revoke_to_user
    @user = User.find(params[:id])
    @user.update!(role: "user")
    redirect_to admin_user_path(@user), notice: "User role revoked to user"
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "Internal notes updated successfully"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:internal_notes)
  end

  def require_reviewer_perms!
    unless current_user&.reviewer_perms?
      redirect_to main_app.root_path, alert: "You are not authorized to access this page."
    end
  end
end
