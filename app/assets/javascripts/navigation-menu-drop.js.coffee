class NavMenu

  constructor: (obj) ->
    @trigger = obj.find('a#menu-trigger')
    @menu = obj.find('div.nav-menu-top')
    @active = @menu.find('.active')
    @openActivity = @menu.find('.on')
    @register_handlers()

  register_handlers: ->
    @trigger.click =>
      @menu.toggle()
    @menu.find('li.activity a.open-close').each (index,item) =>
      item.click =>
        @change_active(item.parent().parent())

  close: (elm) ->
    container = elm.find('fa fa-angle-up')
    container.addClass('fa-angle-down')
    container.removeClass('fa-angle-up')
    container.removeClass('on')

  open: (elm) ->
    container - elm.find('fa fa-angel-down')
    container.addClass('fa-angle-up')
    container.removeClass('fa-angle-down')

  cange_active: (elm) ->
    elm.addClass('on')
    @open(elm)
    @close(@active)
    @active = elm

$(document).ready ->
  window.NavManu = NavMenu
  window.navMenu = new NavMenu($('div.nav-menu'))
