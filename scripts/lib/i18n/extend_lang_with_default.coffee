_ = require 'lodash'
Promise = require '../bluebird'
getSources = require './get_sources'

{ universalPath } = require 'config'
findKeys = universalPath.require 'i18nSrc', 'lib/find_keys'
writeDistVersion = require './write_dist_version'
{ red } = require 'chalk'

module.exports = (lang)->
  Promise.props getSources(lang)
  .then (sources)->

    # Rely fully on Transifex and complete missing with English
    { enFull, langFullTransifex } = sources
    [ full, updateFull, archiveFull ] = findKeys
      enObj: enFull
      langTransifex: langFullTransifex
      markdown: false

    # Rely fully on Transifex and complete missing with English
    { enShort, langShortTransifex } = sources
    [ short, updateShort, archiveShort ] = findKeys
      enObj: enShort
      langTransifex: langShortTransifex
      markdown: true

    # Rely on Wikidata language-specific labels, completed by English labels
    { enWd, langWd, langWdArchive } = sources
    [ wd, updateWd, archiveWd ] = findKeys
      enObj: enWd
      langCurrent: langWd
      langArchive: langWdArchive
      markdown: false

    return writeDistVersion lang, _.extend({}, full, short, wd)

  .catch (err)->
    console.error red("#{lang} err"), err.stack
    throw err
