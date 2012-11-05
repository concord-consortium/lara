module Lightweight
  module LightweightActivityHelper
    def toggle_all(label='all', id_prefix='details_')
      link_to_function("show/hide #{label}", "$$('div[id^=#{id_prefix}]').each(function(d) { Effect.toggle(d,'blind', {duration:0.25}) });")
    end
  end
end
