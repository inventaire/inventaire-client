module.exports = (promises_, _)->
  defaultProps = ['info', 'sitelinks', 'labels', 'descriptions', 'claims']

  API =
    wikidata:
      base: 'https://www.wikidata.org/w/api.php'
      search: (search, language='en', limit='20', format='json')->
        _.buildPath API.wikidata.base,
          action: 'wbsearchentities'
          language: language
          limit: limit
          format: format
          search: search
    wmflabs:
      base: 'http://wdq.wmflabs.org/api'
      query: (query)-> API.wmflabs.base + "?q=#{query}"
      claim: (P, Q)-> API.wmflabs.base + "?q=CLAIM[#{P}:#{Q}]"
      string: (P, string)-> API.wmflabs.base + "?q=STRING[#{P}:#{string}]"

  Q =
    books: [
      'Q571' #book
      'Q2831984' #comic book album
      'Q1004' # bande dessinée
      'Q8261' #roman
      'Q25379' #theatre play
      'Q7725634' #literary work
    ]
    edition: [
      'Q3972943' #publishing
      'Q17902573' #edition
    ]
    humans: ['Q5']
    authors: ['Q36180']

  P =
    'P50': [
      'P58' #screen writer / scénariste
      'P110' # illustrator
    ]

  aliases = {}

  for mainP, aliasedPs of P
    aliasedPs.forEach (aliasedP)->
      aliases[aliasedP] = mainP

  Q.softAuthors = Q.authors.concat(Q.humans)

  methods =
    getEntities: (ids, languages, props=defaultProps, format='json')->
      ids = [ids] if _.isString(ids)
      ids = @normalizeIds(ids)

      languages = [languages] if _.isString(languages)
      unless languages.hasOwnProperty('en') then languages.push 'en'

      query = _.buildPath(API.wikidata.base,
        action: 'wbgetentities'
        languages: languages.join '|'
        format: format
        props: props.join '|'
        ids: ids.join '|'
      ).logIt('query:getEntities')
      return promises_.get(query, {CORS: false})

    normalizeIds: (idsArray)->
      idsArray.map (id)=> @normalizeId(id)

    normalizeId: (id)->
      if @isNumericId(id) then "Q#{id}"
      else if @isWikidataId(id) then id
      else throw new Error 'invalid id provided to normalizeIds'
    getUri: (id)-> 'wd:' + @normalizeId(id)
    isNumericId: (id)-> /^[0-9]+$/.test id
    isWikidataId: (id)-> /^(Q|P)[0-9]+$/.test id
    isWikidataEntityId: (id)-> /^Q[0-9]+$/.test id
    isBook: (P31Array)-> _.haveAMatch Q.books, P31Array
    isAuthor: (P106Array)-> _.haveAMatch Q.authors, P106Array
    isHuman: (P31Array)-> _.haveAMatch Q.humans, P31Array
    type: (entity)->
      if _.isModel entity then P31 = entity.get?('claims')?.P31
      else P31 = entity.claims?.P31
      type = null
      if P31?
        if @isBook(P31) then type = 'book'
        if @isHuman(P31) then type = 'human'
      return type

    wmCommonsThumb: (file, width=500)->
      # requires a user agent
      # requires a proxy that transfers the Content-type headers
      # should eventually be moved on the server-side for cache mutualization
      url = app.API.proxy "http://tools.wmflabs.org/magnus-toolserver/commonsapi.php?image=#{file}&thumbwidth=#{width}"
      return _.preq.resolve $.getXML(url)
      .then (res)->
        # parsing the XML with jQuery
        return $(res).find('thumbnail')?.text?()
      .catch (err)=>
        console.warn "couldnt find #{file} via tools.wmflabs.org, will use the small thumb version"
        return @wmCommonsSmallThumb file, 200

    wmCommonsSmallThumb: (file, width="100")->
      "http://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"

    aliasingClaims: (claims)->
      for id, claim of claims
        # if this Property could be assimilated to another Property
        # add this Property values to the main one
        aliasId = aliases[id]
        if aliasId?
          before = claims[aliasId] or= []
          aliased = claims[id]
          after = _.uniq before.concat(aliased)
          _.log [aliasId, before, id, aliased, aliasId, after], 'entity:aliasingClaims'
          claims[aliasId] = after
      return claims

    getRebasedClaims: (claims)->
      rebased = {}
      for id, claim of claims
        rebased[id] = []
        # adding label as a non-enumerable value
        # needed app.polyglot to be ready
        # if app.polyglot? then rebased[id].label = _.i18n(id)
        if _.isObject claim
          claim.forEach (statement)=>
            # will be overriden at the end of this method
            # so won't be accessible on persisted models
            # testing existance shouldn't be needed thank to the status test
            # but let's keep it for now
            mainsnak = statement.mainsnak
            if mainsnak?
              [datatype, datavalue] = [mainsnak.datatype, mainsnak.datavalue]
              switch datatype
                when 'string', 'commonsMedia' then value = datavalue.value
                when 'wikibase-item' then value = 'Q' + datavalue.value['numeric-id']
                when 'time' then value = @normalizeTime(datavalue.value.time)
                else value = null
              rebased[id].push value  if value?
            else
              # should only happen in snaktype: "novalue" cases or alikes
              console.warn 'no mainsnak found', statement
      return rebased

    normalizeTime: (wikidataTime)->
      # wikidata time looks like: '+00000001862-01-01T00:00:00Z'
      # or "-00000000427-01-01T00:00:00Z" for BC dates
      parts = wikidataTime.split '-'
      switch parts.length
        when 3
          [year, month, rest] = parts
        when 4
          [sign, year, month, rest] = parts
          year = "-" + year
        else console.error "unknown wikidata time format"
      day = rest[0..1]
      return new Date(year, month, day).getTime()

    Q: Q
    P: P
    aliases: aliases

    API: API

  return methods