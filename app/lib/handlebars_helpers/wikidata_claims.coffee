behavior = (name)-> require "modules/general/views/behaviors/templates/#{name}"
wdQ = behavior 'wikidata_Q'
wdP = behavior 'wikidata_P'
SafeString = Handlebars.SafeString

wd = app.lib.wikidata

# handlebars pass a sometime confusing {data:, hash: object} as last argument
# this method is used to make helpers less error-prone by removing this object
neutralizeDataObject = (args)->
  last = args.last()
  if last?.hash? and last.data? then args[0...-1]
  else args

module.exports =
  P: (id)->
    if /^P[0-9]+$/.test id
      wdP({id: id})
    else wdP({id: "P#{id}"})

  Q: (id, linkify, alt)->
    if id?
      unless typeof alt is 'string' then alt = ''
      app.request('qLabel:update')
      return wdQ({id: id, linkify: linkify, alt: alt})

  claim: (args...)->
    [ claims, P, linkify, omitLabel, inline ] = neutralizeDataObject(args)
    if claims?[P]?[0]?
      label = @labelString P, omitLabel
      values = @getQsTemplates(claims[P], linkify)
      return @claimString label, values
    else
      _.log arguments, 'entity:claims:ignored'
      return

  getQsTemplates: (valueArray, linkify)->
    valueArray
    .map (id)=> @Q(id, linkify).trim()
    .join ', '

  timeClaim: (args...)->
    [ claims, P, format, omitLabel, inline ] = neutralizeDataObject(args)
    # default to 'year' and override handlebars data object when args.length is 3
    format or= 'year'
    if claims?[P]?[0]?
      values = claims[P].map (unixTime)->
        time = new Date(unixTime)
        switch format
          when 'year' then return time.getUTCFullYear()
          else return
      label = @labelString P, omitLabel
      values = _.uniq(values).join(" #{_.i18n('or')} ")
      return @claimString label, values, inline

  imageClaim: (claims, P, omitLabel, inline, data)->
    if claims?[P]?[0]?
      file = claims[P][0]
      src = wd.wmCommonsSmallThumb file, 200
      return new SafeString "<img src='#{src}'>"

  stringClaim: (args...)->
    [ claims, P, linkify, omitLabel, inline ] = neutralizeDataObject(args)
    if claims?[P]?[0]?
      label = @labelString P, omitLabel
      values = claims[P]?.join ', '
      return @claimString label, values
    else
      _.log arguments, 'entity:claims:ignored'
      return

  claimString: (label, values, inline)->
    text = "#{label} #{values}"
    if inline then text
    else new SafeString "#{text} <br>"

  labelString: (P, omitLabel)->
    if omitLabel then '' else @P(P)

  wdRemoteHref: (id)-> "https://www.wikidata.org/entity/#{id}"

  wdLocalHref: (id, label)->
    app.request 'get:entity:local:href', 'wd', id, label
