class SettingsController < ApplicationController
  def view
    authorize! :manage, Setting

    @glossary_approved_scripts = ApprovedScript.where(label: "glossary")
    @glossary_approved_script_id = Setting.get("glossary_approved_script_id")

    # when adding other settings here, make sure to add them to the view
    # the update action should handle any new settings added here automatically
  end

  def update
    authorize! :manage, Setting

    settings = params["settings"]
    if settings.present?
      settings.each do |key, value|
        Setting.set(key, value)
      end

      flash[:notice] = "Settings updated"
    else
      flash[:error] = "Settings not found!"
    end

    redirect_to '/settings'
  end
end
