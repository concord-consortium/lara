class LoginMenu
  constructor: (@trigger=$('.login_portal_widget_toggle')) ->
    @trigger = $('.login_portal_widget_toggle')
    @menu    = $('.login_portals_widget')
    @register_handlers()

  position_menu: () ->
    o = @trigger.offset()
    parent = @trigger.parent().parent()
    po = parent.offset()
    margin = 12
    @menu.offset({
      top: o.top + @trigger.height() + margin
      left: o.left
    })
  register_handlers: () ->
    @trigger.click (e) =>
      @menu.toggle()
      @position_menu()
      e.stopPropagation()

    $('body').click () =>
      @menu.hide()
    $(window).resize () =>
      @position_menu()


root = exports ? this
root.LoginMenu = LoginMenu

$('document').ready ->
  root.login_menu = new LoginMenu()
