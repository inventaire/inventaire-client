{ host } = require 'lib/urls'
absolutePath = (url)-> if url?[0] is '/' then host + url else url

module.exports = (key, value, noCompletion)->
  if key in withTransformers then transformers[key](value, noCompletion)
  else value

transformers =
  title: (value, noCompletion)->
    if noCompletion then value else "#{value} - Inventaire"
  url: (canonical)-> host + canonical
  image: (url)-> absolutePath app.API.img(url)

withTransformers = Object.keys transformers
