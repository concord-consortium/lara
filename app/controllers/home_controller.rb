class HomeController < ApplicationController
  def home
    attributes = (params[:filter] || {})
    if params.has_key?('search')
      attributes[:search] = params[:search]
    end
    @filter  = CollectionFilter.new(current_user, LightweightActivity, attributes)
    # TODO: Add 'oficial' to the criteron?
    @activities = @filter.collection.includes(:user,:changed_by,:portal_publications).first(10)
    @filter.klass = Sequence
    # TODO: Add 'oficial' to the criteron?
    @sequences  = @filter.collection.includes(:user,:lightweight_activities).first(10)
  end
  def bad_browser
    render "/home/bad_browser"
  end

  def print_headers
    lines = request.env.map{|key, value| "#{key}: #{value}<br/>"}
    # only show the capitalized keys which are the actual headers
    render text: lines.select{|line| line =~ /^[A-Z]/}.join("\n")
  end

  def interactive_library_admin
    # only allow admins access, see app/models/ability.rb
    # TODO: change to LibraryInteractive when created
    authorize! :manage, :all
  end
end
