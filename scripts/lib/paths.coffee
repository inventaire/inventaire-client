activeFiles = require './active_files'
activeShortkeyLang = activeFiles './public/i18n/src/shortkey'
activeFullkeyLang = activeFiles './public/i18n/src/fullkey'
# assuming that if a transifex source is available for fullkeys
# there will also be one for shortkeys
activeTransifexLang = activeFiles './public/i18n/src/fullkey/transifex'
activeWikidataLang = activeFiles './public/i18n/src/wikidata'
_ = require 'lodash'

module.exports = paths =
  src:
    root: './public/i18n/src'
    fk: (path)-> "#{@root}/fullkey/#{path}"
    sk: (path)-> "#{@root}/shortkey/#{path}"
    wd: (path)-> "#{@root}/wikidata/#{path}"
  distRoot: './public/i18n/dist'
  dist: (lang)-> "#{@distRoot}/#{lang}.json"

PathBuilder = (activeList, srcKey, filenameBuilder)->
  return pathBuilder = (lang, force = false)->
    filename = filenameBuilder lang
    if lang in activeList or force then paths.src[srcKey](filename)
    else null

simple = (lang)-> "#{lang}.json"
archive = (lang)-> "archive/#{lang}.json"
transifex = (lang)-> "transifex/#{lang}.json"

_.extend paths.src,
  fullkey: PathBuilder activeFullkeyLang, 'fk', simple
  fullkeyArchive: PathBuilder activeFullkeyLang, 'fk', archive
  fullkeyTransifex: PathBuilder activeTransifexLang, 'fk', transifex
  shortkey: PathBuilder activeShortkeyLang, 'sk', simple
  shortkeyArchive: PathBuilder activeShortkeyLang, 'sk', archive
  shortkeyTransifex: PathBuilder activeTransifexLang, 'sk', transifex
  wikidata: PathBuilder activeWikidataLang, 'wd', simple
  wikidataArchive: PathBuilder activeWikidataLang, 'wd', archive
