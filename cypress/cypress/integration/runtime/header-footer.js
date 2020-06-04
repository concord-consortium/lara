context('Header and Footer testing', function () {

    let baseUrl = 'https://authoring.staging.concord.org'
    let activity = '/activities/20634'
    let pages = ['307396']
    let themes = ['Default','WATERS', 'Precipitating Change', 'InquirySpace', 'HAS National Geographic']
    
    let pageID = (index) => {
        let pageUrl = '/pages/' + pages[index]
        return pageUrl
    }

    beforeEach(() => {
        cy.visit(baseUrl+activity)
        cy.login()
    })

    function editActivityTheme(i) {
        cy.visit(baseUrl + activity + '/edit')
        cy.get('select#lightweight_activity_theme_id').select(themes[i])
        saveActivity()
    }

    function saveActivity() {
        cy.get('input#save-top').eq(0).click()
    }

    function checkForCCLogo() {
        cy.get('header').find('img').should('have.attr', 'src').should('include','cc-logo')
    }

    function checkForActivityLabel1() {
        cy.get('.activity-nav-title').should('contain', 'Activity: Library Interactive Test').and('be.visible')
    }

    function checkForActivityLabel2() {
        cy.get('.content-hdr').last().should('contain', 'Library Interactive Test').and('be.visible')
    }

    function checkForMenuButton() {
        cy.get('a#menu-trigger').should('be.visible').and('contain', 'Menu').find('i.fa-bars').should('be.visible')
    }

    function checkForPrintLabelButton() {
        cy.get('li.am-print').find('.text').should('contain', 'Print')
    }

    function checkForPrintSideButton() {
        cy.get('li.am-report').find('i.fa-print').should('exist').and('be.visible')
    }

    function checkForFooterPageNavByNumber() {
        cy.get('.footer-nav').find('.pages').should('be.visible').and('contain', '1')
    }

    function checkForFooterPageNavByNextPrev() {
        cy.get('.footer-nav').find('.prev_and_next').within(() => {
            cy.get('.prev.disabled').should('exist')
            cy.get('.next').should('have.attr', 'href').should('include', '/activities')
        })
    }

    function checkForFooterPageNavByNextPrevAlt() {
        cy.get('.bottom-buttons').within(() => {
            cy.get('.forward_nav').find('input.next').should('contain', 'Next').and('be.visible')
        })
    }
    /**
     * ActivityLabel1 is where the Activity Name is displayed in the same div element as the top level page numbers
     * ActivityLabel2 is where the Activity Name is displayed in larger text above the introduction LARA component
     */

    describe('Testing Header and Footers in LARA runtime', () => {
        it('Test Default, Data Games, NextGen themes', () => {
            editActivityTheme(0)
            saveActivity()
            cy.visit(baseUrl+activity+pageID(0))

            checkForCCLogo()
            // checkForActivityLabel1()
            checkForActivityLabel2()
            // checkForPrintLabelButton()
            checkForPrintSideButton()
            // checkForMenuButton()
            // checkForFooterPageNavByNumber()
            // checkForFooterPageNavByNextPrev()
        })
        it('Test WATERS themes', () => {
            editActivityTheme(1)
            saveActivity()
            cy.visit(baseUrl+activity+pageID(0))

            // checkForCCLogo()
            checkForActivityLabel1()
            checkForActivityLabel2()
            checkForPrintLabelButton()
            // checkForPrintSideButton()
            // checkForMenuButton()
            checkForFooterPageNavByNumber()
            checkForFooterPageNavByNextPrev()
        })
        it('Test Precipitating Change themes', () => {
            editActivityTheme(2)
            saveActivity()
            cy.visit(baseUrl+activity+pageID(0))

            // checkForCCLogo()
            checkForActivityLabel1()
            checkForActivityLabel2()
            checkForPrintLabelButton()
            // checkForPrintSideButton()
            // checkForMenuButton()
            // checkForFooterPageNavByNumber()
            // checkForFooterPageNavByNextPrev()
        })
        it('Test Inquiry Space/Building Models/Interactions/RITES Space Theme', () => {
            editActivityTheme(3)
            saveActivity()
            cy.visit(baseUrl+activity+pageID(0))

            checkForCCLogo()
            checkForActivityLabel1()
            // checkForActivityLabel2()
            // checkForPrintLabelButton()
            checkForPrintSideButton()
            checkForMenuButton()
            // checkForFooterPageNavByNumber()
            checkForFooterPageNavByNextPrevAlt()
        })
        it('Test HAS National Geographic Theme', () => {
            editActivityTheme(4)
            saveActivity()
            cy.visit(baseUrl+activity+pageID(0))

            checkForCCLogo()
            checkForActivityLabel1()
            // checkForActivityLabel2()
            // checkForPrintLabelButton()
            // checkForPrintSideButton()
            checkForMenuButton()
            //checkForFooterPageNavByNumber()
            checkForFooterPageNavByNextPrevAlt()
        })

    })
})