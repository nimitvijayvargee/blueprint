class JournalEntriesController < ApplicationController
  before_action :set_project
  before_action :set_journal_entry, only: [ :destroy ]

  def create
    not_found and return unless @project.user == current_user

    @journal_entry = @project.journal_entries.build(journal_entry_params.merge(user: current_user))

    if @journal_entry.save
      ahoy.track("journal_entry_create", project_id: @project.id, user_id: current_user.id)

      redirect_to project_path(@project), notice: "Journal entry created."
    else
      redirect_to project_path(@project), alert: "Could not create journal entry."
    end
  end

  def destroy
    not_found and return unless @journal_entry.user == current_user
    not_found and return unless @project.can_edit?

    @journal_entry.destroy
    redirect_to project_path(@project), notice: "Journal entry deleted."
  end

  private

  def set_project
    @project = current_user.projects.find_by(id: params[:project_id]) || Project.find_by(id: params[:project_id])
    not_found unless @project
  end

  def set_journal_entry
    @journal_entry = @project.journal_entries.find_by(id: params[:id])
    not_found unless @journal_entry
  end

  def journal_entry_params
    permitted = params.require(:journal_entry).permit(:content, :summary, :duration_hours)

    if permitted[:duration_hours].present?
      raw = permitted.delete(:duration_hours).to_s
      hours = Float(raw) rescue nil
      if hours && hours.positive?
        hours_1dp = (hours * 10).round / 10.0
        permitted[:duration_seconds] = (hours_1dp * 3600).round
      end
    end

    permitted
  end
end
