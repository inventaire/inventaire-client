#!/usr/bin/env nodeimport addText from './lib/add_text.coffee';
const minifyJson = jsonString => JSON.stringify(JSON.parse(jsonString));

addText({
  filename: 'actions.jsonld',
  marker: 'ACTIONS',
  modifier: minifyJson
});
