
class NavMenu
  constructor: (obj) ->
    @trigger = obj.find('a#menu-trigger')
    @menu = obj.find('div.nav-menu-top')
    @position_menu()
    @active = @menu.find('.active')
    @openActivity = @menu.find('.on')
    @register_handlers()

  position_menu: () ->
    o = @trigger.offset()
    return unless o
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

    @menu.find('li.activity .open-close').each (inx, elem) =>
      $elem = $(elem)
      $elem.click (e) =>
        @change_active($elem.parent())
        e.stopPropagation()

    $('body').click () =>
      @menu.hide()
    $(window).resize () =>
      @position_menu()

  deactivate: (elm) ->
    container = elm.find('.fa-angle-up')
    container.addClass('fa-bars')
    container.removeClass('fa-angle-up')
    elm.removeClass('on')
  activate: (elm) ->
    container = elm.find('.fa-bars')
    container.addClass('fa-angle-up')
    container.removeClass('fa-bars')
    elm.addClass('on')

  change_active: (elm) ->
    @deactivate(@active)
    @activate(elm)
    @active = elm

root = exports ? this
root.NavMenu = NavMenu
$('document').ready ->
  root.navMenu = new NavMenu($('.nav-menu'))
