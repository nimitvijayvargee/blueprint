class Admin::DesignReviewsController < Admin::ApplicationController
  def index
    @projects = Project.where(is_deleted: false, review_status: :design_pending).includes(:user, :journal_entries).order(created_at: :asc)
  end

  def show
    @project = Project.find(params[:id])
    not_found unless @project
    @design_review = @project.design_reviews.build
  end

  def show_random
    project = Project.where(is_deleted: false, review_status: :design_pending).order("RANDOM()").first
    if project
      redirect_to admin_design_review_path(project)
    else
      redirect_to admin_design_reviews_path, alert: "No projects pending review."
    end
  end

  def create
    @project = Project.find(params[:id])
    @design_review = @project.design_reviews.build(design_review_params)
    @design_review.reviewer = current_user
    @design_review.admin_review = current_user.admin?

    if @design_review.save
      update_project_review_status(@project, @design_review)
      redirect_to admin_random_design_review_path, notice: "Design review submitted successfully. Showing new project."
    else
      redirect_to admin_design_review_path(@project), alert: @design_review.errors.full_messages.to_sentence
    end
  end

  private

  def design_review_params
    params.require(:design_review).permit(:hours_override, :reason, :grant_override_cents, :result, :feedback, :tier_override)
  end

  def update_project_review_status(project, design_review)
    case design_review.result
    when "rejected"
      project.design_reviews.where.not(id: design_review.id).update_all(invalidated: true)
      project.update!(review_status: :design_rejected)
    when "returned"
      project.design_reviews.where.not(id: design_review.id).update_all(invalidated: true)
      project.update!(review_status: :design_needs_revision)
    when "approved"
      valid_approvals = project.design_reviews.where(result: "approved", invalidated: false)
      admin_approvals = valid_approvals.where(admin_review: true)

      if valid_approvals.count >= 2 || admin_approvals.exists?
        project.update!(review_status: :design_approved)
      end
    end
  end
end
