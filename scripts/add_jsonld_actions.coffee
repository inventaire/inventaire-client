#!/usr/bin/env coffee
fs = require 'fs'
index = 'public/index.html'

minifyJson = (jsonString)-> JSON.stringify JSON.parse(jsonString)

actions = fs.readFileSync 'app/assets/actions.jsonld', 'utf-8'

# console.log 'raw actions', actions
minifiedActions = minifyJson actions
# console.log 'minified actions', minifiedActions

html = fs.readFileSync index, 'utf-8'
html = html.replace 'ACTIONS', minifiedActions
fs.writeFileSync index, html
