class ProfilePopup
  constructor: (obj) ->
    @trigger = obj.find('a.popup-trigger')
    @popup = obj.find('div.popup-prompt')
    @re_login = obj.find('a.re-login')
    @position_popup()
    @register_handlers()

  position_popup: () ->
    o = @trigger.offset()
    return unless o
    parent = @trigger.parent().parent()
    po = parent.offset()
    margin_top = 10
    margin_left = (if @popup.hasClass('anonymous-user') then -210 else -130)
    @popup.offset({
      top: o.top + @trigger.height() + margin_top
      left: o.left + @trigger.width() + margin_left
    })
    
  re_login_handler :() ->
    #alert('re login')
    
   
  register_handlers: () ->
    @trigger.click (e) =>
      @popup.toggle()
      @position_popup()
      e.stopPropagation()
    
    @re_login.click (e) =>
      @re_login_handler()
      e.stopPropagation()
      
    $('body').click () =>
      @popup.hide()
    $(window).resize () =>
      @position_popup()


root = exports ? this
root.ProfilePopup = ProfilePopup
$('document').ready ->
  root.profilePopup = new ProfilePopup($('.profile-nav'))
