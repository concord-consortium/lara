class CRater::ItemSettingsController < ApplicationController
  before_filter :set_settings

  def edit
    respond_with_edit_form
  end

  def update
    if @settings.update_attributes(params[:c_rater_item_settings])
      flash[:notice] = "C-Rater Item settings were successfully updated."
      redirect_to(:back)
    else
      render :edit
    end
  end

  private

  def set_settings
    @settings = CRater::ItemSettings.find(params[:id])
  end
end
