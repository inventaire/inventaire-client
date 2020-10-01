// data: labels or descriptions
export default function (lang, originalLang, data) {
  if (!data) { return {} }

  const order = getLangPriorityOrder(lang, originalLang, data)

  while (order.length > 0) {
    const nextLang = order.shift()
    const value = data[nextLang]
    if (value != null) { return { value, lang: nextLang } }
  }

  return {}
};

const getLangPriorityOrder = function (lang, originalLang, data) {
  const order = [ lang ]
  if (originalLang != null) { order.push(originalLang) }
  order.push('en')
  const availableLangs = Object.keys(data)
  return _.uniq(order.concat(availableLangs))
}
