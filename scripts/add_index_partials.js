#!/usr/bin/env coffee

# replace markers in index.html by partials
# /!\ should only be used for piece of html that is of no use in development

addText = require './lib/add_text.coffee'

addText
  filename: 'piwik.html'
  marker: 'PIWIK'
  commented: true

addText
  filename: 'icons.html'
  marker: 'ICONS'
  commented: true
