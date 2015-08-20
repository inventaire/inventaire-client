fs = require 'graceful-fs'

activeFiles = (path)->
  list = fs.readdirSync path
  return list.map (file)-> file.split('.')[0]

activeFilesLists =
activeShortkeyLang = activeFiles './public/i18n/src/shortkey'
activeFullkeyLang = activeFiles './public/i18n/src/fullkey'
# assuming that if a transifex source is available for fullkeys
# there will also be one for shortkeys
activeTransifexLang = activeFiles './public/i18n/src/fullkey/transifex'
activeWikidataLang = activeFiles './public/i18n/src/wikidata'

module.exports =
  src:
    root: "./public/i18n/src"
    fk: (path)-> "#{@root}/fullkey/#{path}"
    sk: (path)-> "#{@root}/shortkey/#{path}"
    wd: (path)-> "#{@root}/wikidata/#{path}"
    fullkey: (lang)->
      if lang in activeFullkeyLang then @fk "#{lang}.json"
      else null
    fullkeyArchive: (lang)->
      if lang in activeFullkeyLang then @fk "archive/#{lang}.json"
      else null
    fullkeyTransifex: (lang)->
      if lang in activeTransifexLang then @fk "transifex/#{lang}.json"
      else null
    shortkey: (lang)->
      if lang in activeShortkeyLang then @sk "#{lang}.json"
      else null
    shortkeyArchive: (lang)->
      if lang in activeShortkeyLang then @sk "archive/#{lang}.json"
      else null
    shortkeyTransifex: (lang)->
      if lang in activeTransifexLang then @sk "transifex/#{lang}.json"
      else null
    wikidata: (lang)->
      if lang in activeWikidataLang then @wd "#{lang}.json"
      else null
    wikidataArchive: (lang)->
      if lang in activeWikidataLang then @wd "archive/#{lang}.json"
      else null
  distRoot: "./public/i18n/dist"
  dist: (lang)-> "#{@distRoot}/#{lang}.json"