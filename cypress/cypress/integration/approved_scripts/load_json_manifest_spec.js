
/* global context, cy, expect, afterEach, beforeEach, it, describe */
/* eslint-disable no-unused-expressions */

context('New approved scripts', function () {
  const newApprovedSriptUrl = `${Cypress.config("baseUrl")}/approved_scripts/new`

  beforeEach(() => {
    cy.login()
  })

  const field = (name) => cy.get(`[name='approved_script[${name}]']`)
  const shouldHaveValue = (name, value) => field(name).should("exist").should("have.value", value)
  const shouldBeEmpty = (name) => shouldHaveValue(name, "")

  describe('when first loaded', () => {
    it('the form should be empty', () => {
      cy.visit(newApprovedSriptUrl)

      shouldBeEmpty("json_url")
      shouldBeEmpty("name")
      shouldBeEmpty("url")
      shouldHaveValue("version", "1")
      shouldBeEmpty("description")
    })
  })

  describe('when the json is loaded', () => {
    const baseUrl = "http://example.com/"
    const jsonUrl = baseUrl + "manifest.json"

    const relativeUrl = "test-plugin.js"
    const fullUrl = "http://foo.bar/test-plugin.js"
    const pluginManifest = {
      "name": "Test LARA Sharing Plugin",
      "label": "TestLARASharingPlugin",
      "url": fullUrl,
      "version": "3",
      "description": "Test Description",
      "authoring_metadata": {
        "components": [
          {
            "label": "test-plugin:activity1",
            "name": "Test: Activity Plugin 1",
            "scope": "activity"
          },
          {
            "label": "test-plugin:activity2",
            "name": "Test: Activity Plugin 2",
            "scope": "activity"
          },
          {
            "label": "test-plugin:embeddable1",
            "name": "Test: Embeddable Plugin 1",
            "scope": "embeddable"
          },
          {
            "label": "test-plugin:embeddable2",
            "name": "Test: Embeddable Plugin 2",
            "scope": "embeddable"
          },
          {
            "label": "test-plugin:embeddable-decoration1",
            "name": "Test: Embeddable Decoration Plugin 1",
            "scope": "embeddable-decoration"
          },
          {
            "label": "test-plugin:embeddable-decoration2",
            "name": "Test: Embeddable Decoration Plugin 2",
            "scope": "embeddable-decoration"
          }
        ]
      }
    }

    beforeEach(() => {
      cy.visit(newApprovedSriptUrl, {
        onBeforeLoad(win) {
          // cypress can't stub fetch yet so we need to do it manually
          win.fetch = (url) => {
            return new Promise((resolve, reject) => {
              resolve({
                json() {
                  pluginManifest.url = url.indexOf("?relativeUrl") !== -1 ? relativeUrl : fullUrl
                  return pluginManifest
                }
              })
            })
          }
        }
      })
    })

    it('the form should have the json values', () => {
      cy.get("#approved_script_json_url").type(jsonUrl);
      cy.get("#approved_script_load_json").click();

      cy.wait(500).then(() => {
        shouldHaveValue("json_url", jsonUrl)
        shouldHaveValue("name", pluginManifest.name)
        shouldHaveValue("url", pluginManifest.url)
        shouldHaveValue("version", pluginManifest.version)
        shouldHaveValue("description", pluginManifest.description)
        shouldHaveValue("authoring_metadata", JSON.stringify(pluginManifest.authoring_metadata))
      })
    })

    it('the form should have the expanded relative url', () => {
      cy.get("#approved_script_json_url").type(jsonUrl + "?relativeUrl");
      cy.get("#approved_script_load_json").click();

      cy.wait(500).then(() => {
        shouldHaveValue("url", baseUrl + relativeUrl)
      })
    })
  })
})
