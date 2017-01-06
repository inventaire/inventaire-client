gutenbergText = (id)-> _.i18n 'on_website', { name: 'Gutenberg.org' }

module.exports =
  'wdt:P1938':
    icon: 'gutenberg'
    text: gutenbergText
    url: (id)-> "#{gutenbergBase()}ebooks/author/#{id}"
  'wdt:P2002':
    icon: 'twitter'
    text: (username)-> "@#{username}"
    url: (username)-> "https://twitter.com/#{username}"
  'wdt:P2003':
    icon: 'instagram'
    text: _.identity
    url: (username)-> "https://instagram.com/#{username}"
  'wdt:P2013':
    icon: 'facebook'
    text: _.identity
    url: (facebookId)-> "https://facebook.com/#{facebookId}"
  'wdt:P2034':
    icon: 'gutenberg'
    text: gutenbergText
    url: (id)-> "#{gutenbergBase()}ebooks/#{id}"

gutenbergBase = ->
  base = if _.smallScreen() then 'http://m.' else 'https://www.'
  return "#{base}gutenberg.org/"
