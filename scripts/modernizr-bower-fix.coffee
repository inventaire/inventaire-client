fs = require 'fs'

modernizrBowerJson = './bower_components/modernizr/.bower.json'
json = JSON.parse fs.readFileSync(modernizrBowerJson).toString()
json.main = 'modernizr.js'
updatedJson = JSON.stringify json, null, 4
fs.writeFileSync(modernizrBowerJson, updatedJson)

process.stdout.write "Fixed: 'main' added to Modernizr .bower.json\n"