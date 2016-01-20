_ = require 'lodash'
Promise = require 'bluebird'
getSources = require './get_sources'

{ universalPath } = require 'config'
findKeys = universalPath.require 'i18nSrc', 'lib/find_keys'
updateAndArchive = require './update_and_archive'
writeDistVersion = require './write_dist_version'

module.exports = extendLangWithDefault = (lang)->
  Promise.props getSources(lang)
  .then (sources)->

    { enFull, langFull, langFullTransifex, langFullArchive } = sources
    [full, updateFull, archiveFull] = findKeys
      enObj: enFull
      langCurrent: langFull
      langTransifex: langFullTransifex
      langArchive: langFullArchive
      markdown: false

    { enShort, langShort, langShortTransifex, langShortArchive } = sources
    [short, updateShort, archiveShort] = findKeys
      enObj: enShort
      langCurrent: langShort
      langTransifex: langShortTransifex
      langArchive: langShortArchive
      markdown: true

    { enWd, langWd, langWdArchive } = sources
    [wd, updateWd, archiveWd] = findKeys
      enObj: enWd
      langCurrent: langWd
      langTransifex: {}
      langArchive: langWdArchive
      markdown: false

    updateAndArchive
      lang: lang
      updateFull: updateFull
      archiveFull: archiveFull
      updateShort: updateShort
      archiveShort: archiveShort
      updateWd: updateWd
      archiveWd: archiveWd

    writeDistVersion lang, _.extend({}, full, short, wd)

  .catch (err)->
    console.error "#{lang} err".red, err.stack
    throw err
