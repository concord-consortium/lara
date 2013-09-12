class HomeController < ApplicationController
  def home
    @filter  = CollectionFilter.new(current_user, LightweightActivity, params[:filter] || {})
    # TODO: Add 'oficial' to the criteron?
    @activities = @filter.collection.first(10)
    @filter.klass = Sequence
    # TODO: Add 'oficial' to the criteron?
    @sequences  = @filter.collection.first(10)
  end
end
