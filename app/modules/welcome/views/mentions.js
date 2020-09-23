export default Marionette.ItemView.extend({
  template: require('./templates/mentions'),
  serializeData () {
    const { lang } = app.user
    const data = {}
    for (const category in this.options.data) {
      const listsByLang = this.options.data[category]
      data[category] = tailorForLang(listsByLang, lang).map(format)
    }
    return data
  }
})

var tailorForLang = function (listsByLang, lang) {
  // first the user lang
  let orderedData = listsByLang[lang] || []
  // then English
  if (lang !== 'en') {
    if (listsByLang.en != null) { orderedData = orderedData.concat(listsByLang.en) }
  }
  // then other langs
  for (lang in listsByLang) {
    const list = listsByLang[lang]
    if ((lang !== lang) && (lang !== 'en')) {
      orderedData = orderedData.concat(list)
    }
  }

  // return only the first 6 elements
  return orderedData.slice(0, 6)
}

var format = function (entry) {
  if (entry.picture != null) { entry.picture = `/img/assets/${entry.picture}` }
  return entry
}
