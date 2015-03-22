#= require nav_menu

describe 'NavMenu', () ->

  describe 'basic menu function', () ->
    menu = null
    beforeEach () ->
      loadFixtures('navigation-menu.html')
      menu = new NavMenu($('div.nav-menu'))

    it 'has a jQuery object attribute "trigger"', () ->
      expect(menu.trigger).toBeDefined()
      expect(menu.trigger).toEqual('a#menu-trigger')

    it 'has a jQuery object attribute "menu"', () ->
      expect(menu.menu).toBeDefined()
      expect(menu.menu).toEqual('div.nav-menu-top')

    it 'has a jQuery object attribute "active"', () ->
      expect(menu.active).toBeDefined()
      expect(menu.openActivity).toBeDefined()

    it 'calls `toggle()` on the menu when trigger is clicked', () ->
      spyOn(menu.menu, 'toggle')
      menu.trigger.click()
      expect(menu.menu.toggle).toHaveBeenCalled()

    it 'is not showing the menu at page load', () ->
      expect(menu.menu.css('display')).toBe('none')

    it 'is showing the menu after one click', () ->
      menu.trigger.click()
      expect(menu.menu.css('display')).toBe('block')

    it 'hides the menu on the second click', () ->
      menu.trigger.click()
      menu.trigger.click()
      expect(menu.menu.css('display')).toBe('none')

  describe 'when the menu has a sequence', () ->
    menu = null
    beforeEach () ->
      loadFixtures('navigation-menu-sequence.html')
      menu = new NavMenu($('.nav-menu'))

    it "exists", () ->
      expect(menu).toBeDefined()

    it 'has an element in the "active" attribute', () ->
      expect(menu.active).toEqual('li.activity.active')
      expect(menu.openActivity).toEqual('li.activity.on')

    it 'calls change_active when activities are clicked', () ->
      spyOn(menu, 'change_active')
      initial_active = $('#initial_selection')
      initial_active.find('a.open-close').trigger('click')
      expect(menu.change_active).toHaveBeenCalled()
      expect(menu.active).toEqual(initial_active)

    describe 'change_active', () ->
      it 'changes the currently active activity', () ->
        prev_active = menu.active
        target_active = $('#test_target')
        menu.change_active(target_active)
        expect(menu.active).toHaveClass('on')
        expect(prev_active).not.toHaveClass('on')
        expect(menu.active.find('ol li.page')[0]).toBeVisible()

