/**
 * Test cases:
 * 
 * 1.1 Test Width Layout status
 * 2.1 Test special rich text changes if possible (images)
 * 2.2 Student answers save
 * 3.  Check if required (submit button)
 * 5.  Hints have rich text and display in ? button
 * 
 * 
 * Notes: I think I can use the blank ID from the authoring in some way
 *        in order to grab the element in the dom. Any verification
 *        method where I can use the match term?
 * 
 */

 class FITB {
    getFITBContent() {
        return cy.get('.fill-in-the-blank')
    }
    getFITBInput() {
        return this.getFITBContent().find('input')
    }
    // getFITBInput(id) {
    //     return this.getFITBContent().find('input').eq(id)
    // }
 }
 export default FITB;