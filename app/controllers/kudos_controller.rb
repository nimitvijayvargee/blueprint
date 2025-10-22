class KudosController < ApplicationController
  before_action :set_project

  def create
    not_found and return if @project.user == current_user

    @kudo = @project.kudos.build(kudo_params.merge(user: current_user))

    if @kudo.save
      redirect_to project_path(@project), notice: "Kudos sent!"
    else
      redirect_to project_path(@project), alert: @kudo.errors.full_messages.join(", ")
    end
  end

  def destroy
    @kudo = @project.kudos.find_by(id: params[:id])
    not_found and return unless @kudo
    not_found and return unless @kudo.user == current_user

    @kudo.destroy
    redirect_to project_path(@project), notice: "Kudos removed."
  end

  private

  def set_project
    @project = Project.find_by(id: params[:project_id])
    not_found unless @project
  end

  def kudo_params
    params.require(:kudo).permit(:content)
  end
end
