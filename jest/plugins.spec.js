// Manually setup dependencies for LARA API... For now, it's only jQuery and jQuery UI.
// It's still possible, I'm not sure if it's possible long term. If it's only an interim solution,
// a good side effect is that it documents dependencies for given module. It might get too annoying though.
// Writing tests in Jest is awesome, but it requires proper setup of the JS code and dependencies management.
const $ = require("../app/assets/javascripts/jquery-2.2.4");
global.$ = $;
global.jQuery = $;
require("../app/assets/javascripts/plugins");

describe("Plugins", () => {

  it("should exist", () => {
    expect(Plugins).toBeDefined();
  })

  describe("initPlugin", () => {
    const learnerData = '{"answered": true }'
    const authorData  = '{"configured": true }'
    const name = 'myPlugin'
    const div = '<div classname="myplugin" />'
    const savePath = 'save/1/2'
    const loadPath = 'load/1/2'

    const pluginStatePaths = {
      savePath: savePath,
      loadPath: loadPath
    }
    const pluginConstructor = jest.fn()

    const config = {
      name: name,
      url: "http://google.com/",
      pluginId: name,
      authorData: authorData,
      learnerData: learnerData,
      div: div
    }
    beforeAll(() => {
      // Implicit test of registerPlugin
      Plugins.registerPlugin(name,pluginConstructor)
      Plugins.initPlugin(name, config, pluginStatePaths)
    })

    it('should call the plugins constructor with the config', () => {
      expect(pluginConstructor).toHaveBeenCalledTimes(1)
      expect(pluginConstructor).toHaveBeenCalledWith(config)
    })
    it('should maintain a list of plugins', () => {
      expect(Plugins._pluginLabels).toContain(name)
      expect(Plugins._pluginStatePaths[name]).toEqual(pluginStatePaths)
      expect(Plugins._pluginClasses[name]).toEqual(pluginConstructor)
    })

    describe("saveLearnerPluginState", () => {
      const state = '{"new": "state"}'
      let ajax  = jest.fn()
      beforeEach(()=> {
        ajax = jest.fn((opts) => {
          opts.success(state)
        })
        global.$.ajax = ajax
      })

      describe("When save succeeds", () => {
        it('should save data', () => {
          expect.assertions(1)
          return Plugins.saveLearnerPluginState(name, state)
            .then((d) => expect(d).toEqual(state))
        })
      })

      describe("When save fails", () => {
        beforeEach(()=> {
          ajax = jest.fn((opts) => {
            opts.error("jqXHR","error","boom")
          })
          global.$.ajax = ajax
        })
        it('should save data', () => {
          expect.assertions(1)
          return Plugins.saveLearnerPluginState(name, state)
            .catch((e) => expect(e).toEqual("boom"))
        })
      })

    })
  })

});
