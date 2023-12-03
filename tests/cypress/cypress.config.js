import { defineConfig } from 'cypress'

export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3005',
    supportFile: 'tests/cypress/support/e2e.js',
    fixturesFolder: 'tests/cypress/support/e2e.js',
    screenshotsFolder: 'tests/cypress/screenshots',
    specPattern: 'tests/cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    defaultCommandTimeout: 5000,
    video: false,
    experimentalRunAllSpecs: true,
    experimentalStudio: true,
    trashAssetsBeforeRuns: true,
    // Default viewport: override with cy.viewport(width, height)
    viewportWidth: 1280,
    viewportHeight: 768,
    setupNodeEvents (on, config) {
      // implement node event listeners here
    },
  },
})
