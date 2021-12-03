describe('welcome', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  it('should display the landing screen', () => {
    cy.url('/welcome')
    cy.contains('h2', 'inventaire')
    cy.contains('Sign up')
    cy.contains('Login')
  })
})
