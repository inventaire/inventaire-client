// Various custom commands and overwrite of existing commands.
// See https://on.cypress.io/custom-commands

const password = '12345678'

Cypress.Commands.add('signup', username => {
  if (!username) username = 'hello' + Math.random().toString().slice(2, 10)
  cy.session(username, () => {
    cy.request({
      method: 'post',
      url: '/api/auth?action=signup',
      body: {
        username,
        email: `${username}@hello.hello`,
        password
      },
    })
  })
})

Cypress.Commands.add('login', (username = 'adamsberg') => {
  // More about cy.session(): https://docs.cypress.io/api/commands/session#Notes
  cy.session(username, () => {
    signUpIfNecessary(username)
    loginReq(username)
  })
})

function signUpIfNecessary (username) {
  cy.request({
    method: 'get',
    url: `/api/auth?action=username-availability&username=${
      username}`,
    failOnStatusCode: false,
  })
  // .then() is not a JS Promise, but some Cypress stuff
  // See https://learn.cypress.io/cypress-fundamentals/understanding-the-asynchronous-nature-of-cypress
  .then(({ body }) => {
    if (body.status !== 400) {
      cy.signup(username)
    }
  })
}

function loginReq (username) {
  cy.request({
    method: 'post',
    url: '/api/auth?action=login',
    body: {
      username,
      password
    },
  })
}
