module.exports = (lang, originalLang, data)->
  order = getLangPriorityOrder lang, originalLang, data
  while order.length > 0
    nextLang = order.shift()
    value = data[nextLang]
    if value? then return value

  return

getLangPriorityOrder = (lang, originalLang, data)->
  order = [ lang ]
  if originalLang? then order.push originalLang
  order.push 'en'
  availableLangs = Object.keys data
  return _.uniq order.concat(availableLangs)
