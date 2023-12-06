describe('entities layout', () => {
  beforeEach(() => {
    cy.visit('/entity/wd:Q535')
  })

  it('should navigates to work url when clicking on work title', () => {
    cy.contains('le poète dans les révolutions', { matchCase: false })
    .click()
    cy.url().should('include', '/entity/wd:Q87990101')
  })

  it('should filter works when typing work title in filter field', () => {
    cy.contains('.works-browser', 'Hernani')
    cy.get('.works-browser-text-filter')
    .type('Poète{enter}')
    cy.contains('.works-browser', 'Le Poète dans les révolutions')
    cy.get('.works-browser')
    .should('not.include.text', 'Hernani')
  })

  it('should display works browser sections', () => {
    // More callbacks at : https://glebbahmutov.com/blog/cypress-should-callback/
    cy.get('.works-browser-section')
    .should(div => {
      expect(div.eq(0)).to.contain('Series')
      expect(div.eq(1)).to.contain('Works')
      expect(div.eq(2)).to.contain('Articles')
    })
  })
})
