require_dependency "lightweight/application_controller"

module Lightweight
  class LightweightActivitiesController < ApplicationController
    before_filter :set_activity, :except => [:index, :new, :create]

    def index
      if current_user.blank?
        @activities ||= Lightweight::LightweightActivity.find(:all)
      else
        @activities = Lightweight::LightweightActivity.find_all_by_user_id(current_user.id)
      end
    end

    def show
      # If we're given an offering ID, use that to set the offering; otherwise just take the first one.
      @offering = params[:offering_id] ? Portal::Offering.find(params[:offering_id]) : @activity.offerings.first
      redirect_to activity_page_offering_show_path(@activity, @activity.pages.first, @offering)
    end

    def new
      @activity = Lightweight::LightweightActivity.new()
    end

    def create
      @activity = Lightweight::LightweightActivity.create(params[:lightweight_activity])
      if current_user
        @activity.user = current_user
      end
      if @activity.save
        flash[:notice] = "Lightweight Activity #{@activity.name} was created."
        redirect_to edit_activity_path(@activity)
      else
        flash[:warning] = "There was a problem creating the new Lightweight Activity."
        render :new
      end
    end

    def edit
    end

    def update
      if @activity.update_attributes(params[:lightweight_activity])
        flash[:notice] = "Activity #{@activity.name} was updated."
        redirect_to edit_activity_path(@activity)
      else
        flash[:warning] = "There was a problem updating activity #{@activity.name}."
        redirect_to edit_activity_path(@activity)
      end
    end

    def destroy
      if @activity.delete
        flash[:notice] = "Activity #{@activity.name} was deleted."
        redirect_to activities_path
      else
        flash[:warning] = "There was a problem deleting activity #{@activity.name}."
        redirect_to edit_activity_path(@activity)
      end
    end

    private
    def set_activity
      @activity = Lightweight::LightweightActivity.find(params[:id])
    end
  end
end
