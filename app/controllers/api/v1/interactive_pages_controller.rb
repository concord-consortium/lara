class Api::V1::InteractivePagesController < ApplicationController
  layout false
  before_filter :set_interactive_page

  ## Queries:
  def get_sections
    render_page_sections_json
  end

  ## Mutations
  def set_sections
    param_sections = params['sections'] # array of [{:id,:layout}]
    old_sections = @interactive_page.sections
    # Put them in the correct order:
    index = 1
    new_sections = param_sections.map do |s|
      section = Section.find(s['id'])
      position = index
      if section.position != position
        section.position = position
        section.save!(validate: false)
      end
      index = index + 1
      section
    end
    # TBD: Remove 'unused' sections?
    # sections.to_remove = old_sections.filter { |s| s.id != }
    @interactive_page.sections = new_sections
    @interactive_page.save!
    render_page_sections_json
  end

  def create_section
    @interactive_page.add_section
    render_page_sections_json
  end

  def update_section
    section_params = params['section']
    section_id = section_params.delete('id')
    section = Section.find(section_id)
    section.update_attributes(section_params)
    render_page_sections_json
  end

  def get_interactive_list
    begin
      authorize! :read, @interactive_page

      scope = params[:scope] || "page"
      supports_snapshots = params[:supportsSnapshots]

      if scope != "page"
        raise "Invalid scope parameter: #{scope}"
      end

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
            id: "interactive_#{pi.id}",
            pageId: @interactive_page.id,
            name: i.name,
            section: pi.old_section != nil ? pi.old_section : "assessment_block",
            url: i.url,
            thumbnailUrl: i.thumbnail_url,
            supportsSnapshots: !i.no_snapshots
          }
        end

      render :json => { :success => true, interactives: interactives}

    rescue CanCan::AccessDenied
      return render :json => { :success => false, :message => "You are not authorized to get the interactive list from the requested page"}
    rescue => error
      return render :json => { :success => false, :message => error.message}
    end
  end

  private

  def render_page_sections_json
    sections = @interactive_page.sections.map do |s|
      {
        id: s.id.to_s,
        layout: s.layout
      }
    end
    render :json => {
      :success => true,
      sections: sections,
      id: @interactive_page.id
    }
  end

  def set_interactive_page
    begin
      @interactive_page = InteractivePage.find(params['id'])
    rescue ActiveRecord::RecordNotFound
      render :json => { :success => false, :message => "Could not find interactive page ##{params['id']}"}
    end
  end
end
