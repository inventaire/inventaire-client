images_ = require './images'

module.exports =
  P2002:
    label: -> images_.icon 'twitter'
    text: (username)-> "@#{username}"
    url: (username)-> "https://twitter.com/#{username}"
