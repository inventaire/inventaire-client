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
  ]
  humans: ['Q5']
  authors: ['Q36180']

Q.softAuthors = Q.authors.concat(Q.humans)

module.exports = (Promises)->

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
      return Promises.get(query, false)

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
    isBook: (P31Array)->_.haveAMatch Q.books, P31Array
    isAuthor: (P106Array)-> _.haveAMatch Q.authors, P106Array
    isHuman: (P31Array)-> _.haveAMatch Q.humans, P31Array

    Q: Q

    API: API

  return methods