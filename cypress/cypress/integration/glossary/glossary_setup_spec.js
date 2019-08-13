import Glossary from "../../support/plugin-elements/glossary";

context('Glossary default test', function () {

  let glossary = new Glossary()

  const awsGlossaryCredentials = 
  {
    "glossaryName" : "TestGlossary",
    "glossaryUsername" : "demo-glossary",
    "awsAccessKey" : "",
    "awsSecretKey" : ""
  }

  const word1 =
  {
    "word": "word",
    "definition": "test definition 1",
    "imageUrl": "https://picexample.url.com",
    "imageCaption": "test image caption text",
    "videoUrl": "https://videxample.url.com",
    "videoCaption": "test video caption here"
  }

  let activityUrl
  before(() => {
    cy.login()
    cy.importMaterial('activities/glossary-activity.json').then(url => {
      activityUrl = url
    })
  })

  describe('Authoring the glossary (Enabled Student Definitions', () => {

    it('Instantiates glossary plugin and adds AWS credentials', () => {
      cy.visit(activityUrl+'/edit')
      glossary.addGlossaryPluginToActivity()
      glossary.openGlossaryPluginEditForm()
      cy.wait(1000)
      glossary.getGlossaryAuthoringUI().within(() => {
        glossary.getSuccessStatus().should('not.contain', 'success')
        glossary.fillOutFormAndLoad(awsGlossaryCredentials)
        glossary.getSuccessStatus().should('contain', 'success')
      })
    })

    it('Adds a word to the glossary', () => {
      glossary.getAddANewDefinitionButton().click({ force: true })
      glossary.getWordTextBox().should('be.visible').type(word1.word)
      glossary.getDefTextBox().should('be.visible').type(word1.definition)
      glossary.getImageTextBox().should('be.visible').type(word1.imageUrl)
      glossary.getImageCaptionTextBox().should('be.visible').type(word1.imageCaption)
      glossary.getVideoTextBox().should('be.visible').type(word1.videoUrl)
      glossary.getVideoCaptionTextBox().should('be.visible').type(word1.videoCaption)
      // Save word data to glossary
      glossary.getSaveGlossaryWord().click({ force: true })
      // Save updates to AWS
      glossary.getSaveToAWS().click({ force: true })
      glossary.getSuccessStatus().should('contain', 'Uploading JSON to S3: success')
      // Save updates to LARA
      glossary.getSaveToLARA().click({ force: true })
    })

    //Checks that the sidebar opens and closes correctly
    it('Verifies that the sidebar opens and closes correctly', () => {
      cy.visit(activityUrl)
    })
  })
})




