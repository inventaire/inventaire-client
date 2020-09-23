element = null

# Adapted from https://stackoverflow.com/a/9609450/3324977
module.exports = (str)->
  # Ignore this lib in test environments
  unless document.createElement? then return str

  unless _.isNonEmptyString str then return str

  element or= document.createElement 'div'
  str = str
    # strip script/html tags
    .replace /<script[^>]*>([\S\s]*?)<\/script>/gmi, ''
    .replace /<\/?\w(?:[^"'>]|"[^"]*"|'[^']*')*>/gmi, ''
  element.innerHTML = str
  str = element.textContent
  element.textContent = ''
  return str
