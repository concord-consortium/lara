import AuthoringPage from "../../support/authoring-page.cy.js";
import TEWindowShadeAuthoringPage from "../../support/teacher-edition-window-shade-authoring.cy.js";

const authoringPage = new AuthoringPage;
const teWindowShadeAuthoringPage = new TEWindowShadeAuthoringPage;

const tip = {
    tip1: "Teacher Tip",
    tip1Content: "Teacher Tip Content",
    tip2: "Theory & Background",
    tip2Content: "Theory & Background Content",
    tip3: "Discussion Points",
    tip3Content: "Discussion Points Content",
    tip4: "Digging Deeper",
    tip4Content: "Digging Deeper Content",
    tip5: "How to Use This Interactive",
    tip5Content: "How to Use This Interactive Content",
    tip6: "Framing The Activity",
    tip6Content: "Framing The Activity Content",
    tip7: "Demo",
    tip7Content: "Demo Content",
    tip8: "Offline Activity",
    tip8Content: "Offline Activity Content"
};

context("Test Authoring Preview", () => {
  before(() => {
    cy.visit("");
    cy.loginLARAWithSSO(Cypress.config().username, Cypress.env("password"));
    authoringPage.launchActivity("Test Automation TEWindowShade Activity");
    cy.deleteItem();
  });

  describe("LARA TE Window Shade", () => {
    it("Add TE Window Shade", () => {
      authoringPage.getAddItem().click();
      authoringPage.getItemPickerSearch().type("Teacher Edition");
      authoringPage.getItemPickerList().contains("Teacher Edition: Window Shade").click();
      authoringPage.getAddItemButton().click();
      cy.wait(6000);
      authoringPage.getSectionMenuEdit().click();
      cy.wait(6000);
      authoringPage.getEditItemDialog().should("exist");
      teWindowShadeAuthoringPage.selectTipType(tip.tip1);
      teWindowShadeAuthoringPage.typeContent(tip.tip1Content);
      teWindowShadeAuthoringPage.getButtonTitle(tip.tip1);
      teWindowShadeAuthoringPage.verifyWindowShadeContent(tip.tip1Content);
      teWindowShadeAuthoringPage.selectTipType(tip.tip2);
      teWindowShadeAuthoringPage.typeContent(tip.tip2Content);
      teWindowShadeAuthoringPage.getButtonTitle(tip.tip2);
      teWindowShadeAuthoringPage.verifyWindowShadeContent(tip.tip2Content);
      teWindowShadeAuthoringPage.selectTipType(tip.tip3);
      teWindowShadeAuthoringPage.typeContent(tip.tip3Content);
      teWindowShadeAuthoringPage.getButtonTitle(tip.tip3);
      teWindowShadeAuthoringPage.verifyWindowShadeContent(tip.tip3Content);
      teWindowShadeAuthoringPage.selectTipType(tip.tip4);
      teWindowShadeAuthoringPage.typeContent(tip.tip4Content);
      teWindowShadeAuthoringPage.getButtonTitle(tip.tip4);
      teWindowShadeAuthoringPage.verifyWindowShadeContent(tip.tip4Content);
      teWindowShadeAuthoringPage.selectTipType(tip.tip5);
      teWindowShadeAuthoringPage.typeContent(tip.tip5Content);
      teWindowShadeAuthoringPage.getButtonTitle(tip.tip5);
      teWindowShadeAuthoringPage.verifyWindowShadeContent(tip.tip5Content);
      teWindowShadeAuthoringPage.selectTipType(tip.tip6);
      teWindowShadeAuthoringPage.typeContent(tip.tip6Content);
      teWindowShadeAuthoringPage.getButtonTitle(tip.tip6);
      teWindowShadeAuthoringPage.verifyWindowShadeContent(tip.tip6Content);
      teWindowShadeAuthoringPage.selectTipType(tip.tip7);
      teWindowShadeAuthoringPage.typeContent(tip.tip7Content);
      teWindowShadeAuthoringPage.getButtonTitle(tip.tip7);
      teWindowShadeAuthoringPage.verifyWindowShadeContent(tip.tip7Content);
      teWindowShadeAuthoringPage.selectTipType(tip.tip8);
      teWindowShadeAuthoringPage.typeContent(tip.tip8Content);
      teWindowShadeAuthoringPage.getButtonTitle(tip.tip8);
      teWindowShadeAuthoringPage.verifyWindowShadeContent(tip.tip8Content);
      teWindowShadeAuthoringPage.selectMediaType("image");
      teWindowShadeAuthoringPage.typeMedia("https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg");
      teWindowShadeAuthoringPage.clickSaveButton();
    });
    it("Verify TE Question Wrapper In Authoring Preview", () => {
      cy.wait(4000);
      teWindowShadeAuthoringPage.getAuthoringPreviewButtonTitle(tip.tip8);
      teWindowShadeAuthoringPage.verifyAuthoringPreviewWindowShadeContent(tip.tip8Content);
      teWindowShadeAuthoringPage.verifyAuthoringPreviewImageUrl("https://learn-resources.concord.org/tutorials/images/brogan-acadia.jpg");
    });
    it("Delete TE Window Shade", () => {
      cy.wait(4000);
      authoringPage.getSectionMenuDelete().click();
    });
  });
});
