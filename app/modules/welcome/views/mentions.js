module.exports = Marionette.ItemView.extend
  template: require './templates/mentions'
  serializeData: ->
    { lang } = app.user
    data = {}
    for category, listsByLang of @options.data
      data[category] = tailorForLang(listsByLang, lang).map format
    return data

tailorForLang = (listsByLang, lang)->
  # first the user lang
  orderedData = listsByLang[lang] or []
  # then English
  if lang isnt 'en'
    if listsByLang.en? then orderedData = orderedData.concat listsByLang.en
  # then other langs
  for lang, list of listsByLang
    unless lang is lang or lang is 'en'
      orderedData = orderedData.concat list

  # return only the first 6 elements
  return orderedData[0..5]

format = (entry)->
  if entry.picture? then entry.picture = "/img/assets/#{entry.picture}"
  return entry
