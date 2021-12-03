#!/usr/bin/env node
const { writeFileSync } = require('fs')
const path = require('path')
const { port } = require('config').webpackDevServer

const config = {
  baseUrl: `http://localhost:${port}`,
  video: false,
  fixturesFolder: path.resolve(__dirname, './fixtures/index.js'),
  integrationFolder: path.resolve(__dirname, './integration'),
  pluginsFile: path.resolve(__dirname, './plugins/index.cjs'),
  screenshotsFolder: path.resolve(__dirname, './screenshots'),
  supportFile: path.resolve(__dirname, './support/index.js'),
  videosFolder: path.resolve(__dirname, './videos'),
}

console.log('config', config)

writeFileSync(path.resolve(__dirname, './cypress.json'), JSON.stringify(config, null, 2))
