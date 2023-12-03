describe('inventory:main user', () => {
  beforeEach(() => {
    cy.login()
  })

  it('should navigate to the home screen when logged in', () => {
    cy.visit('/')
    cy.contains('Add books')
  })

  it('should navigate to book import', () => {
    cy.visit('/')
    cy.contains('Add books').click()
  })
})
