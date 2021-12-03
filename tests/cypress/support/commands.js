// Various custom commands and overwrite of existing commands.
// See https://on.cypress.io/custom-commands

Cypress.Commands.add('login', () => {
  const username = 'hello' + Math.random().toString().slice(2, 10)
  cy.request({
    method: 'post',
    url: '/api/auth?action=signup',
    body: { username, email: `${username}@hello.hello`, password: '12345678' },
  })
})
