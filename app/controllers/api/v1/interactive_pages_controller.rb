class Api::V1::InteractivePagesController < ApplicationController
  layout false
  before_filter :set_interactive

  def get_interactive_list
    begin
      authorize! :read, @interactive_page

      scope = params[:scope] || "page"
      supports_snapshots = params[:supportsSnapshots]

      if scope == "page"
        interactives = @interactive_page
          .interactive_page_items
          .select do |pi|
            i = pi.embeddable
            case supports_snapshots
            when "true"
              !i.no_snapshots
            when "false"
              i.no_snapshots
            else
              # supportsSnapshots is optional
              true
            end
          end
          .map do |pi|
            i = pi.embeddable
            {
              id: pi.id,
              pageId: @interactive_page.id,
              name: i.name,
              section: pi.section != nil ? pi.section : "assessment_block",
              url: i.url,
              thumbnailUrl: i.thumbnail_url,
              supportsSnapshots: !i.no_snapshots
            }
          end

        render :json => { :success => true, interactives: interactives}
      else
        render :json => { :success => false, :message => "Invalid scope parameter: #{scope}"}
      end
    rescue CanCan::AccessDenied
      render :json => { :success => false, :message => "You are not authorized to get the interactive list from the requested page"}
    end
  end

  private

  def set_interactive
    begin
      @interactive_page = InteractivePage.find(params['id'])
    rescue ActiveRecord::RecordNotFound
      render :json => { :success => false, :message => "Could not find interactive page ##{params['id']}"}
    end
  end
end
