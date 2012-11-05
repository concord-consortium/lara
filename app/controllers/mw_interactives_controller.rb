require_dependency "lightweight/application_controller"

module Lightweight
  class MwInteractivesController < ApplicationController
    before_filter :set_interactive, :except => [:new, :create]

    def new
      create
    end

    def create
      if (params[:page_id])
        @page = Lightweight::InteractivePage.find(params[:page_id])
        @interactive = Lightweight::MwInteractive.create!()
        Lightweight::InteractiveItem.create!(:interactive_page => @page, :interactive => @interactive)
        flash[:notice] = "Your new MW Interactive has been created."
        redirect_to edit_page_mw_interactive_path(@page, @interactive)
      else
        @interactive = Lightweight::MwInteractive.create!()
        flash[:notice] = "Your new MW Interactive has been created."
        redirect_to edit_mw_interactive_path(@interactive)
      end
    end

    def edit
    end

    def update
      if (@interactive.update_attributes(params[:mw_interactive]))
        # respond success
        flash[:notice] = 'Your MW Interactive was updated'
      else
        flash[:warning] = "There was a problem updating your MW Interactive"
      end
      respond_to do |format|
        if @page
          format.html { redirect_to edit_page_mw_interactive_path(@page, @interactive) }
        else
          format.html { redirect_to edit_mw_interactive_path(@interactive) }
        end
      end
    end

    def destroy
      @interactive.interactive_item.delete
      if @interactive.delete
        flash[:notice] = 'Your interactive was deleted.'
        redirect_to edit_activity_page_path(@page.lightweight_activity, @page)
      else
        flash[:warning] = 'There was a problem deleting the interactive.'
        redirect_to edit_activity_page_path(@page.lightweight_activity, @page)
      end
    end

    private
    def set_interactive
      @interactive = Lightweight::MwInteractive.find(params[:id])
      if params[:page_id]
        @page = Lightweight::InteractivePage.find(params[:page_id])
      end
    end
  end
end
