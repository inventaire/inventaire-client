describe('signup', () => {
  it('should create an account', () => {
    cy.visit('/signup')
    const username = 'hello' + Math.random().toString().slice(2, 10)
    cy.get('input[name="username"]').type(username)
    cy.get('input[name="email"]').type(`${username}@hello.hello`)
    cy.get('input[name="password"]').type('12345678{enter}')
    cy.url(`/inventory/${username}`)
  })
})
