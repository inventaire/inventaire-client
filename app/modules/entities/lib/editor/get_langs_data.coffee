{ langs:activeLangs } = require 'lib/active_languages'
availableLangList = require 'lib/available_lang_list'

module.exports = (selectedLang, labels)->
  availableLangs = Object.keys labels
  highPriorityLangs = [ app.user.lang, 'en' ]
  allLangs = _.uniq availableLangs.concat(highPriorityLangs, activeLangs)
  # No distinction is made between available langs and others
  # as we can't style the <option> element anyway
  return availableLangList allLangs, selectedLang
