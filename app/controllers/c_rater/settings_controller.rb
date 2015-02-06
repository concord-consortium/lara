class CRater::SettingsController < ApplicationController
  before_filter :set_settings

  def edit
    respond_with_edit_form
  end

  def update
    if @settings.update_attributes(params[:c_rater_settings])
      flash[:notice] = "C-Rater settings were successfully updated."
      redirect_to(:back)
    else
      render :edit
    end
  end

  private

  def set_settings
    @settings = CRater::Settings.find(params[:id])
  end
end
