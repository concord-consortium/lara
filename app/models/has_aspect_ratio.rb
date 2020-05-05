module HasAspectRatio

  ASPECT_RATIO_DEFAULT_WIDTH   = 576
  ASPECT_RATIO_DEFAULT_HEIGHT  =  435
  ASPECT_RATIO_DEFAULT_METHOD  = 'DEFAULT'
  ASPECT_RATIO_MANUAL_METHOD   = 'MANUAL'
  ASPECT_RATIO_MAX_METHOD      = 'MAX'

  def available_aspect_ratios
    [
      HasAspectRatio::ASPECT_RATIO_DEFAULT_METHOD,
      HasAspectRatio::ASPECT_RATIO_MANUAL_METHOD,
      HasAspectRatio::ASPECT_RATIO_MAX_METHOD
    ].map do |key|
      { key: key, value: I18n.t("INTERACTIVE.ASPECT_RATIO.#{key}") }
    end
  end

  # returns the aspect ratio of the interactive, dividing the width by the height.
  # For an interactive with a native width of 400 and native height of 200,
  # the aspect_ratio will be 2.
  # If ASPECT_RATIO_MAX_METHOD is being used, it is expected that the available
  # width and height are provided as arugments used to calculated an aspect_ratio
  def aspect_ratio(avail_width=nil, avail_height=nil)
    case self.aspect_ratio_method
      when ASPECT_RATIO_DEFAULT_METHOD
        return ASPECT_RATIO_DEFAULT_WIDTH / ASPECT_RATIO_DEFAULT_HEIGHT.to_f
      when ASPECT_RATIO_MANUAL_METHOD
        return self.native_width/self.native_height.to_f
      when ASPECT_RATIO_MAX_METHOD
        width  = avail_width  || ASPECT_RATIO_DEFAULT_WIDTH
        height = avail_height || ASPECT_RATIO_DEFAULT_HEIGHT
        return width / height.to_f
    end
  end

  def height(avail_width, avail_height=nil)
    return avail_width / self.aspect_ratio(avail_width, avail_height)
  end

end
