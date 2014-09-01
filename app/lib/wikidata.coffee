defaultProps = ['info', 'sitelinks', 'labels', 'descriptions', 'claims']

module.exports =
  getEntities: (ids, languages, props=defaultProps, format='json')->
    languages = [app.user.lang, 'en']  unless languages?
    ids = [ids] if typeof ids is 'string'
    ids = @normalizeIds(ids)
    languages = [languages] if typeof languages is 'string'
    query = _.buildPath(app.API.wikidata.get,
      action: 'wbgetentities'
      languages: languages.join '|'
      format: format
      props: props.join '|'
      ids: ids.join '|'
    ).label('getEntities query')
    return $.getJSON(query)

  parseEntityData: (wikidataAPIAnswer, id)->
    return wikidataAPIAnswer.entities[id]


  normalizeIds: (idsArray)->
    return idsArray.map wd.normalizeId

  normalizeId: (id)->
    if wd.isNumericId(id) then "Q#{id}"
    else if (id[0] is 'Q' or id[0] is 'P') then id
    else throw new Error 'invalid id provided to normalizeIds'

  isNumericId: (id)-> /^[0-9]{1,}$/.test id

  getExtract: (extractRoute)->
    _.log extractRoute, 'extract extractRoute'
    return $.getJSON extractRoute
    .then (res)->
      _.log res, 'extract res'
      if res.parse?.text? then res.parse.text['*']
      else throw new Error 'wikipedia article not found: check if the request lang and title match'
    .fail (err)->
      _.log err, 'getWikipediaExtract err'

  Q:
    books: [
      'Q571' #book
      'Q2831984' #comic book album
      'Q1004' # bande dessinée
      'Q8261' #roman
      'Q25379' #theatre play
    ]
    humans: ['Q5']
    authors: ['Q36180']