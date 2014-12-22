behavior = (name)-> require "modules/general/views/behaviors/templates/#{name}"
wdQ = behavior 'wikidata_Q'
wdP = behavior 'wikidata_P'
SafeString = Handlebars.SafeString

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

  claim: (claims, P, linkify, omitLabel, inline, data)->
    if claims?[P]?[0]?
      label = @P(P)
      # when linkify args is omitted, the {data:,hash: }
      # makes it truthy, thus the stronger test:
      linkify = linkify is true
      values = claims[P].map (id)=> @Q(id, linkify)
      values = values.join ', '
      return @claimString label, values
    else
      _.log arguments, 'entity:claims:ignored'
      return

  timeClaim: (claims, P, format, omitLabel, inline, data)->
    # default to 'year' and override handlebars data object when args.length is 3
    unless _.isString(format) then format = 'year'
    if claims?[P]?[0]?
      values = claims[P].map (unixTime)->
        time = new Date(unixTime)
        switch format
          when 'year' then return time.getUTCFullYear()
          else return
      label = if omitLabel then '' else @P(P)
      values = _.uniq(values).join(" #{_.i18n('or')} ")
      return @claimString label, values, inline

  claimString: (label, values, inline)->
    text = "#{label} #{values}"
    if inline then text
    else new SafeString "#{text} <br>"

  wdRemoteHref: (id)-> "https://www.wikidata.org/entity/#{id}"

  wdLocalHref: (id, label)->
    href = "/entity/wd:#{id}"
    href += "/#{label}"  if label?
    return href
