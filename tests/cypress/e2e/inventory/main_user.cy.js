describe('inventory:main user', () => {
  before(() => {
    cy.login()
  })

  it('should navigate to the home screen when logged in', () => {
    cy.visit('/')
    cy.contains('Add books')
  })
})
