describe('signup', () => {
  it('should create an account', () => {
    cy.visit('/signup')
    const username = 'hello' + Math.random().toString().slice(2, 10)
    cy.get('input[name="username"]').focus().type(username)
    cy.get('input[name="email"]').focus().type(`${username}@hello.hello`)
    cy.get('input[name="new-password"]').focus().type('12345678{enter}')
    cy.url(`/inventory/${username}`)
  })
})
