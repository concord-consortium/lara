class HomeController < ApplicationController
  def home
    @sequences  = Sequence.newest.last(10)
    @activities = LightweightActivity.public.newest.last(10)
  end
end
