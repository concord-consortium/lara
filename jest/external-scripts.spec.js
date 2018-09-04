require("../app/assets/javascripts/external-scripts")

describe("ExternalScript", () => {
  it("should exist", () => {
    expect(ExternalScripts).toBeDefined()
  })
  it("should not be null", ()=> {
    expect(ExternalScripts).not.toBeNull()
  })
  describe("register", ()=> {
    it("should exist", () => {
      expect(ExternalScripts.register).toBeDefined()
    })
  })
})

