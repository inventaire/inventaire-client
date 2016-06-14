module.exports = Marionette.ItemView.extend
  template: require './templates/mentions'
  serializeData: ->
    { lang } = app.user
    data = {}
    for k, v of @options.data
      data[k] = tailorForLang v, lang
    return _.log data, 'data'

tailorForLang = (data, lang)->
  # first the user lang
  orderedData = data[lang] or []
  # then English
  if lang isnt 'en'
    if data.en? then orderedData = orderedData.concat data.en
  # then other langs
  for k, v of data
    unless k is lang or k is 'en'
      orderedData = orderedData.concat data[k]

  # return only the first 6 elements
  return orderedData[0..5]
