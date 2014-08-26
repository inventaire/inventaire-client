proxy = (route)-> '/proxy/' + route
defaultProps = ['info', 'sitelinks', 'labels', 'descriptions', 'claims']

module.exports =
  getEntities: (ids, languages=[app.user.lang, 'en'], props=defaultProps, format='json')->
    ids = [ids] if typeof ids is 'string'
    ids = @normalizeIds(ids)
    pipedIds = ids.join '|'
    languages = [languages] if typeof languages is 'string'
    pipedLanguages = languages.join '|'
    pipedProps = props.join '|'
    query = "#{app.API.wikidata.get}?action=wbgetentities&languages=#{pipedLanguages}&format=#{format}&props=#{pipedProps}&ids=#{pipedIds}".label('getEntities query')
    return $.getJSON(query)


  serializeWikiData: (entityModel)->
    lang = app.user.lang
    model = entityModel.toJSON()
    model.attrs = attrs =
      pictures: model.flat?.pictures
      P31: model.flat?.claims.P31
      id: model.title

    if label = wd.getEntityValue(model,'labels', lang)
      attrs.label = label

    if description = wd.getEntityValue(model,'descriptions', lang)
      attrs.description = description

    if wikilink = wd.getWikipediaTitle(model.sitelinks, lang)
      attrs.wikipedia = "https://#{lang}.wikipedia.org/wiki/#{wikilink}"

    _.log model, 'wikidata entity model'
    return attrs

  normalizeIds: (idsArray)->
    return idsArray.map wd.normalizeId

  normalizeId: (id)->
    if wd.isNumericId(id) then "Q#{id}"
    else if (id[0] is 'Q' or id[0] is 'P') then id
    else throw new Error 'invalid id provided to normalizeIds'

  isNumericId: (id)-> /^[0-9]{1,}$/.test id

  rebaseClaimsValueToClaimsRoot: (entity)->
    flat =
      claims: new Object
      pictures: new Array
    for id, claim of entity.claims
      # propLabel = wdProps[id]
      flat.claims[id] = new Array
      if typeof claim is 'object'
        claim.forEach (statement)->
          switch statement.mainsnak.datatype
            when 'string'
              flat.claims[id].push(statement._value = statement.mainsnak.datavalue.value)
            when 'wikibase-item'
              statement._id = statement.mainsnak.datavalue.value['numeric-id']
              flat.claims[id].push "Q#{statement._id}"
            else flat.claims[id].push(statement.mainsnak)
          if id is 'P18'
            flat.pictures.push _.wmCommonsThumb(statement.mainsnak.datavalue.value)
      # flat.claims["#{id} - #{propLabel}"] = flat.claims[id]
    entity.flat = flat

  getEntityValue: (entity, props, lang=app.user.lang)->
    _.log arguments, 'getEntityValue args'
    if entity[props]?[lang]?.value?
      return entity[props][lang].value
    else if entity[props]?.en?.value?
      return entity[props].en.value
    else return

  getWikipediaTitle: (sitelinks, lang=app.user.lang)->
    _.log arguments, 'getWikipediaLink args'
    if sitelinks?["#{lang}wiki"]?.title?
      return sitelinks["#{lang}wiki"].title
    else if sitelinks?.enwiki?.title?
      return sitelinks.enwiki.title
    else return

  # getWikipediaLink: (sitelinks, lang=app.user.lang)->
  #   title = wd.getWikipediaTitle((sitelinks, lang)
  #   return "https://#{lang}.wikipedia.org/wiki/#{title}"

  getWikipediaInfo: (entity, lang=app.user.lang)->
    info = {}
    info.title = title = wd.getWikipediaTitle(entity.sitelinks, lang)
    info.url = "https://#{lang}.wikipedia.org/wiki/#{title}"

  getWikipediaExtractFromTitle: (title, lang = app.user.lang)->
    request = "https://#{lang}.wikipedia.org/w/api.php?" +
    "action=parse&section=0&prop=text&format=json&page=#{title}"
    _.log request, 'getWikipediaExtractFromTitle request'
    return $.getJSON proxy(request)
    .then (res)->
      return res.parse.text['*']
    .fail (err)->
      _.log err, 'getWikipediaExtract err'

  getWikipediaExtractFromEntity: (entity, lang = app.user.lang)->
    title = wd.getWikipediaTitle(entity.sitelinks)
    return wd.getWikipediaExtractFromTitle(title)