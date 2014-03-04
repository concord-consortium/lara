
class NavMenu
  constructor: (obj) ->
    @trigger = obj.find('a#menu-trigger')
    @menu = obj.find('div.nav-menu-top')
    @active = @menu.find('.active')
    @openActivity = @menu.find('.on')
    @register_handlers()

  register_handlers: () ->
    @trigger.click (e) =>
      @menu.toggle()
      e.stopPropagation()

    @menu.find('li.activity a.open-close').each (inx, elem) =>
      $elem = $(elem)
      $elem.click (e) =>
        console.log("open-close click")
        @change_active($elem.parent().parent())
        e.stopPropagation()

    $('body').click () =>
      console.log("body click")
      @menu.hide()

  deactivate: (elm) ->
    container = elm.find('fa-angle-up')
    container.addClass('fa-angle-down')
    container.removeClass('fa-angle-up')
    elm.removeClass('on')

  activate: (elm) ->
    container = elm.find('fa-angle-down')
    container.addClass('fa-angle-up')
    container.removeClass('fa-angle-down')
    elm.addClass('on')

  change_active: (elm) ->
    @deactivate(@active)
    @activate(elm)
    @active = elm

root = exports ? this
root.NavMenu = NavMenu
$('document').ready ->
  root.navMenu = new NavMenu($('div.nav-menu'))
