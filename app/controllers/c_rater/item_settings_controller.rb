class CRater::ItemSettingsController < ApplicationController
  before_action :set_settings

  def edit
    respond_with_edit_form
  end

  def update_params
    params.require(:c_rater_item_settings).permit(:item_id, :score_mapping_id)
  end

  def update
    if @settings.update_attributes(update_params)
      flash[:notice] = "C-Rater Item settings were successfully updated."
      redirect_back(fallback_location: c_rater_item_settings_path)
    else
      render :edit
    end
  end

  private

  def set_settings
    @settings = CRater::ItemSettings.find(params[:id])
  end
end
