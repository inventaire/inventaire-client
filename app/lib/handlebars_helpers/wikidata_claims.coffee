{ SafeString } = Handlebars

wd_ = require 'lib/wikidata'
linkify_ = require './linkify'
images_ = require './images'
platforms_ = require './platforms'
{ P, Q, neutralizeDataObject, getQsTemplates, labelString, claimString } = require './claims_helpers'

module.exports =
  P: P
  Q: Q
  claim: (args...)->
    [ claims, pid, linkify, omitLabel, inline ] = neutralizeDataObject args
    if claims?[pid]?[0]?
      label = labelString pid, omitLabel
      values = getQsTemplates claims[pid], linkify
      return claimString label, values

  timeClaim: (args...)->
    [ claims, pid, format, omitLabel, inline ] = neutralizeDataObject args
    # default to 'year' and override handlebars data object when args.length is 3
    format or= 'year'
    if claims?[pid]?[0]?
      values = claims[pid].map (unixTime)->
        time = new Date(unixTime)
        switch format
          when 'year' then return time.getUTCFullYear()
          else return
      label = labelString pid, omitLabel
      values = _.uniq(values).join(" #{_.i18n('or')} ")
      return claimString label, values, inline

  imageClaim: (claims, pid, omitLabel, inline, data)->
    if claims?[pid]?[0]?
      file = claims[pid][0]
      src = wd_.wmCommonsSmallThumb file, 200
      return new SafeString "<img src='#{src}'>"

  stringClaim: (args...)->
    [ claims, pid, linkify, omitLabel, inline ] = neutralizeDataObject args
    if claims?[pid]?[0]?
      label = labelString pid, omitLabel
      values = claims[pid]?.join ', '
      return claimString label, values

  urlClaim: (args...)->
    [ claims, pid ] = neutralizeDataObject args
    firstUrl = claims?[pid]?[0]
    if firstUrl?
      label = images_.icon 'link'
      cleanedUrl = _.dropProtocol firstUrl
      values = linkify_ cleanedUrl, firstUrl, 'link website'
      return claimString label, values

  platformClaim: (args...)->
    [ claims, pid ] = neutralizeDataObject args
    firstUsername = claims?[pid]?[0]
    if firstUsername?
      platform = platforms_[pid]
      label = platform.label()
      values = linkify_ platform.text(firstUsername), platform.url(firstUsername), 'link social-network'
      return claimString label, values

  wdRemoteHref: (id)-> "https://www.wikidata.org/entity/#{id}"

  wdLocalHref: (id, label)->
    app.request 'get:entity:local:href', 'wd', id, label
