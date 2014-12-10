behavior = (name)-> require "modules/general/views/behaviors/templates/#{name}"
wdQ = behavior 'wikidata_Q'
wdP = behavior 'wikidata_P'
SafeString = Handlebars.SafeString

module.exports =
  P: (id)->
    if /^P[0-9]+$/.test id
      wdP({id: id})
    else wdP({id: "P#{id}"})

  Q: (claims, P, link)->
    if claims?[P]?
      # when link args is omitted, the {data:,hash: }
      # makes it truthy, thus the stronger test:
      link = link is true
      values = claims[P].map (Q)-> wdQ({id: Q, link: link})
      return values.join ', '
    else
      _.log arguments, 'claim couldnt be displayed by Handlebars'
      return

  claim: (claims, P, link)->
    if claims?[P]?[0]?
      label = @P(P)
      value = @Q(claims, P, link)
      return new SafeString "#{label} #{value} <br>"

  timeClaim: (claims, P, format='year')->
    if claims?[P]?[0]?
      values = claims[P].map (unixTime)->
        time = new Date(unixTime)
        switch format
          when 'year' then return time.getUTCFullYear()
          else return
      values = _.uniq(values)
      return new SafeString values.join(' ' + _.i18n('or') + ' ')