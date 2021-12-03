describe('welcome', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('should display the landing screen', () => {
    cy.url('/welcome')
    cy.contains('h2', 'inventaire')
    cy.get('.signupRequest').should('have.length', 2)
    cy.get('.loginRequest').should('have.length', 2)
  })
})
