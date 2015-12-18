_ = require 'lodash'
Promise = require 'bluebird'
getSources = require './get_sources'

{ universalPath } = require 'config'
findKeys = universalPath.require 'i18nSrc', 'lib/find_keys'
updateAndArchive = require './update_and_archive'
writeDistVersion = require './write_dist_version'

module.exports = extendLangWithDefault = (lang)->
  Promise.all getSources(lang)
  .then (args)->
    rethrowErrors(args)

    [
      enFull, enShort, enWd
      langFull, langFullArchive, langFullTransifex
      langShort, langShortArchive, langShortTransifex
      langWd, langWdArchive
    ] = args

    fullArgs = [enFull, langFull, langFullArchive, langFullTransifex, false]
    shortArgs = [enShort, langShort, langShortArchive, langShortTransifex, true]
    wdArgs = [enWd, langWd, langWdArchive, null, false]

    [full, updateFull, archiveFull] = findKeys.apply null, fullArgs
    [short, updateShort, archiveShort] = findKeys.apply null, shortArgs
    [wd, updateWd, archiveWd] = findKeys.apply null, wdArgs

    updateAndArchive lang, updateFull, archiveFull, updateShort, archiveShort, updateWd, archiveWd
    writeDistVersion lang, _.extend({}, full, short, wd)

  .catch (err)-> console.error "#{lang} err".red, err.stack

rethrowErrors = (args)->
  args.forEach (arg)->
    if arg instanceof Error then throw arg
