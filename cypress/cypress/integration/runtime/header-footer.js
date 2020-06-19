context("Header and Footer testing", function () {
  // Need to get all themes synced in order to run on all environments.
  // Tests only run on 2 themese currently
  let activityUrl;
  const activityPath = "activities/activity_with_arg_block_section.json";
  const themes = [
    "Default",
    "HAS National Geographic",
    // "WATERS",
    // "Precipitating Change",
    // "InquirySpace"
  ];

  beforeEach(() => {
    cy.login();
    cy.importMaterial(activityPath).then((url) => (activityUrl = url));
  });

  afterEach(() => {
    cy.deleteMaterial(activityUrl);
  });

  function editActivityTheme(i) {
    cy.visit(activityUrl + "/edit");
    cy.get("select#lightweight_activity_theme_id").parent().click({ force: true }).then(() => {
        cy.get("select#lightweight_activity_theme_id").select(themes[i]);
      });
    saveActivity();
  }
  function viewStudentRuntime() {
    cy.visit(activityUrl).then(() => {
      cy.get(".pagination-link").contains("1").click();
    });
  }
  function saveActivity() {
    cy.get("input#save-top").eq(0).click();
  }
  function checkForCCLogo() {
    cy.get("header").find("img").should("have.attr", "src").should("include", "cc-logo");
  }
  function checkForActivityLabel1() {
    cy.get(".activity-nav-title").should("contain", "[Cypress] Arg Block Test").and("be.visible");
  }
  function checkForActivityLabel2() {
    cy.get(".content-hdr").last().should("contain", "[Cypress] Arg Block Test").and("exist");
  }
  function checkForMenuButton() {
    cy.get("a#menu-trigger").should("be.visible").and("contain", "Menu").find("i.fa-bars").should("be.visible");
  }
  function checkForPrintLabelButton() {
    cy.get("li.am-print").find(".text").should("contain", "Print");
  }
  function checkForPrintSideButton() {
    cy.get("li.am-report").find("i.fa-print").should("exist").and("be.visible");
  }
  function checkForFooterPageNavByNumber() {
    cy.get(".footer-nav").find(".pages").should("be.visible").and("contain", "1");
  }
  function checkForFooterPageNavByNextPrev() {
    cy.get(".footer-nav").find(".prev_and_next").within(() => {
        cy.get(".prev.disabled").should("exist");
        cy.get(".next").should("have.attr", "href").should("include", "/activities");
      });
  }
  function checkForFooterPageNavByNextPrevAlt() {
    cy.get(".bottom-buttons").within(() => {
      cy.get(".forward_nav").find("input.next").should("contain", "Next").and("be.visible");
    });
  }
  /**
   * ActivityLabel1 is where the Activity Name is displayed in the same div element as the top level page numbers
   * ActivityLabel2 is where the Activity Name is displayed in larger text above the introduction LARA component
   */

  describe("Testing Header and Footers in LARA runtime", () => {
    it("Test Default, Data Games, NextGen themes", () => {
      editActivityTheme(0);
      viewStudentRuntime();

      checkForCCLogo();
      checkForActivityLabel2();
      checkForPrintSideButton();
    });
    it.skip("Test WATERS themes", () => {
      editActivityTheme(1);
      viewStudentRuntime();

      checkForActivityLabel1();
      checkForActivityLabel2();
      checkForPrintLabelButton();
      checkForFooterPageNavByNumber();
      checkForFooterPageNavByNextPrev();
    });
    it.skip("Test Precipitating Change themes", () => {
      editActivityTheme(2);
      viewStudentRuntime();

      checkForActivityLabel1();
      checkForActivityLabel2();
      checkForPrintLabelButton();
    });
    it.skip("Test Inquiry Space/Building Models/Interactions/RITES Space Theme", () => {
      editActivityTheme(3);
      viewStudentRuntime();

      checkForCCLogo();
      checkForActivityLabel1();
      checkForPrintSideButton();
      checkForMenuButton();
      checkForFooterPageNavByNextPrevAlt();
    });
    it("Test HAS National Geographic Theme", () => {
      editActivityTheme(1);
      viewStudentRuntime();

      checkForCCLogo();
      checkForActivityLabel1();
      checkForMenuButton();
      checkForFooterPageNavByNextPrevAlt();
    });
  });
});
