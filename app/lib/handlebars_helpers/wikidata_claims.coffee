behavior = (name)-> require "modules/general/views/behaviors/templates/#{name}"
wdQ = behavior 'wikidata_Q'
wdP = behavior 'wikidata_P'
SafeString = Handlebars.SafeString

module.exports =
  P: (id)->
    if /^P[0-9]+$/.test id
      wdP({id: id})
    else wdP({id: "P#{id}"})

  Q: (id, link, alt)->
    if id?
      unless typeof alt is 'string' then alt = ''
      app.request('qLabel:update')
      return wdQ({id: id, link: link, alt: alt})

  claim: (claims, P, link)->
    if claims?[P]?[0]?
      label = @P(P)
      # when link args is omitted, the {data:,hash: }
      # makes it truthy, thus the stronger test:
      link = link is true
      values = claims[P].map (id)=> @Q(id, link)
      values = values.join ', '
      return new SafeString "#{label} #{values} <br>"
    else
      _.log arguments, 'claim couldnt be displayed by Handlebars'
      return

  timeClaim: (claims, P, format='year')->
    if claims?[P]?[0]?
      values = claims[P].map (unixTime)->
        time = new Date(unixTime)
        switch format
          when 'year' then return time.getUTCFullYear()
          else return
      values = _.uniq(values)
      return new SafeString values.join(' ' + _.i18n('or') + ' ')