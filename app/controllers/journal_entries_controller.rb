class JournalEntriesController < ApplicationController
  before_action :set_project
  before_action :set_journal_entry, only: [ :update, :destroy ]

  def create
    @journal_entry = @project.journal_entries.build(journal_entry_params.merge(user: current_user))

    if @journal_entry.save
      redirect_to project_path(@project), notice: "Journal entry created."
    else
      redirect_to project_path(@project), alert: "Could not create journal entry."
    end
  end

  def update
    if @journal_entry.update(journal_entry_params)
      redirect_to project_path(@project), notice: "Journal entry updated."
    else
      redirect_to project_path(@project), alert: "Could not update journal entry."
    end
  end

  def destroy
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
    params.require(:journal_entry).permit(:content)
  end
end
