#!/usr/bin/env nodeimport addText from './lib/add_text.coffee';
/* eslint-disable
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const minifyJson = jsonString => JSON.stringify(JSON.parse(jsonString))

addText({
  filename: 'actions.jsonld',
  marker: 'ACTIONS',
  modifier: minifyJson
})
