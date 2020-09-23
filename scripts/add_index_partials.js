#!/usr/bin/env node// replace markers in index.html by partials
// /!\ should only be used for piece of html that is of no use in development

import addText from './lib/add_text.coffee'

addText({
  filename: 'piwik.html',
  marker: 'PIWIK',
  commented: true
})

addText({
  filename: 'icons.html',
  marker: 'ICONS',
  commented: true
})
