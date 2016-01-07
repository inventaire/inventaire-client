[ target ] = process.argv.slice(2)

module.exports = ->
  if target is 'prod' then 'https://inventaire.io'
  else 'http://localhost:3006'
