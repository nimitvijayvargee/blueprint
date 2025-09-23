class Admin::AllowedEmailsController < Admin::ApplicationController
  def index
    @q = params[:q].to_s.strip
    scope = AllowedEmail.order(created_at: :desc)
    scope = scope.where("email ILIKE ?", "%#{@q}%") if @q.present?
    @pagy, @allowed_emails = pagy(scope, items: 50)
    @allowed_email = AllowedEmail.new
  end

  def create
    input = params[:allowed_email][:email].to_s
    emails = input.split(/[\s,]+/).map(&:strip).reject(&:blank?).map(&:downcase).uniq

    created = 0
    emails.each do |em|
      record = AllowedEmail.new(email: em)
      created += 1 if record.save
    end

    redirect_to admin_allowed_emails_path, notice: "Added #{created} email(s)."
  end

  def destroy
    allowed = AllowedEmail.find_by(id: params[:id])
    allowed&.destroy
    redirect_to admin_allowed_emails_path, notice: "Removed #{allowed&.email || 'email'}."
  end
end
