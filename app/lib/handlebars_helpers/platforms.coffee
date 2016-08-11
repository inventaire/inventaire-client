images_ = require './images'

module.exports =
  'wdt:P1938':
    label: -> images_.icon 'download'
    text: (id)-> _.i18n "ebooks on gutenberg.org"
    url: (id)-> "#{gutenbergBase()}ebooks/author/#{id}"
  'wdt:P2002':
    label: -> images_.icon 'twitter'
    text: (username)-> "@#{username}"
    url: (username)-> "https://twitter.com/#{username}"
  'wdt:P2003':
    label: -> images_.icon 'instagram'
    text: (username)-> username
    url: (username)-> "https://instagram.com/#{username}"
  'wdt:P2013':
    label: -> images_.icon 'facebook'
    text: (facebookId)-> facebookId
    url: (facebookId)-> "https://facebook.com/#{facebookId}"
  'wdt:P2034':
    label: -> images_.icon 'download'
    text: (id)-> _.i18n 'download ebook'
    url: (id)-> "#{gutenbergBase()}ebooks/#{id}"

gutenbergBase = ->
  base = if _.smallScreen() then 'http://m.' else 'https://www.'
  return "#{base}gutenberg.org/"
