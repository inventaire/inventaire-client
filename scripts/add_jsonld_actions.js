#!/usr/bin/env node
import addText from './lib/add_text.coffee'
const minifyJson = jsonString => JSON.stringify(JSON.parse(jsonString))

addText({
  filename: 'actions.jsonld',
  marker: 'ACTIONS',
  modifier: minifyJson
})
