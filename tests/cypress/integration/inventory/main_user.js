describe('inventory:main user', () => {
  before(() => {
    cy.login()
  })

  it('should be the home screen when connected', () => {
    cy.visit('/')
    cy.url().should('include', '/inventory')
  })
})
