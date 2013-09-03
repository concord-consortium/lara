class HomeController < ApplicationController
  def home
    @filter  = CollectionFilter.new(current_user, LightweightActivity, params[:filter] || {})
    @activities = @filter.collection.last(10)
    @filter.klass = Sequence
    @sequences  = @filter.collection.last(10)
  end
end
