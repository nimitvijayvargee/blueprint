class Admin::UsersController < Admin::ApplicationController
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
end
