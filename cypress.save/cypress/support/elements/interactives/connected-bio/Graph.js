class Graph {
    getGraph() {
        return cy.get('[data-test="line-chart"]')
    }
    getGraphScrollbar() {
        return cy.get('#line-chart-controls > div.rc-slider.scrubber')
    }
    getPopShowData(){
        return cy.get('.upper-right')
    }
    togglePopShowData(){
        return this.getPopShowData().click();
    }
    getFooterButton(){
        return cy.get('.footer .button-holder')
    }
    getGraphCanvas(){
        return cy.get('[data-test=line-chart] canvas')
    }
    toggleWhiteMouseLegend(){
        this.getGraphCanvas().click(100, 526, {force:true})
    }
    toggleTanMouseLegend(){
        this.getGraphCanvas().click(200, 526, {force:true})
    }
    toggleBrownMouseLegend(){
        this.getGraphCanvas().click(300, 526, {force:true})
    }
}

export default Graph;