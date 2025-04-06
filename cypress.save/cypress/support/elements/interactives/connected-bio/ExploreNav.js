class ExploreNav {

  getExploreView(view) {
    let target
    if (view == 'heredity') {
      target = 'breeding'
    } else {
      target = view
    }
    return cy.get('.explore-button.' + target + '.clickable')
  }


  clickExploreView(view) {
    this.getExploreView(view).click({force:true})
  }
}
export default ExploreNav;
