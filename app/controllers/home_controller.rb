class HomeController < ApplicationController
  def home
    @sequences = Sequence.last(10)
    @activities = LightweightActivity.public.last(10)
  end
end
