fs = require 'fs'
index = 'public/index.html'

module.exports = (params)->
  { filename, marker, modifier, commented } = params
  text = fs.readFileSync "app/assets/#{filename}", 'utf-8'
  if modifier? then text = modifier text
  html = fs.readFileSync index, 'utf-8'
  # useful for markers directly inserted in the html
  # which would be displayed on screen if not wrapped in a html comment
  if commented then marker = "<!-- #{marker} -->"
  html = html.replace marker, text
  fs.writeFileSync index, html
