defaultProps = ['info', 'sitelinks', 'labels', 'descriptions', 'claims']

module.exports =
  getEntities: (ids, languages, props=defaultProps, format='json')->
    languages = [app.user.lang, 'en']  unless languages?
    ids = [ids] if _.isString(ids)
    ids = @normalizeIds(ids)
    languages = [languages] if _.isString(languages)
    query = _.buildPath(app.API.wikidata.get,
      action: 'wbgetentities'
      languages: languages.join '|'
      format: format
      props: props.join '|'
      ids: ids.join '|'
    ).logIt('getEntities query')
    return $.getJSON(query)

  normalizeIds: (idsArray)-> idsArray.map wd.normalizeId

  normalizeId: (id)->
    if wd.isNumericId(id) then "Q#{id}"
    else if wd.isWikidataId(id) then id
    else throw new Error 'invalid id provided to normalizeIds'

  isNumericId: (id)-> /^[0-9]+$/.test id
  isWikidataId: (id)-> /^(Q|P)[0-9]+$/.test id
  isWikidataEntityId: (id)-> /^Q[0-9]+$/.test id

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