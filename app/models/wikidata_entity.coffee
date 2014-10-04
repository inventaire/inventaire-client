books = require 'lib/books'

module.exports = class WikidataEntity extends Backbone.NestedModel
  initialize: (entityData)->
    lang = app.user.lang
    @setAttributes(@attributes, lang)
    @relocateClaims(@attributes)
    @getWikipediaInfo(@attributes, lang)
    @findAPicture(@attributes)

  setAttributes: (attrs, lang)->
    @id = @get 'id'
    pathname = "/entity/#{@id}"

    if label = @getEntityValue attrs, 'labels', lang
      @set 'label', label
      @set 'title', label
      pathname += "/" + _.softEncodeURI(label)

    @set 'pathname', pathname

    @set 'uri', "wd:#{@id}"

    if description = @getEntityValue attrs, 'descriptions', lang
      @set 'description', description

    if wikilink = @getWikipediaTitle attrs.sitelinks
      @set 'wikipedia', "https://#{lang}.wikipedia.org/wiki/#{wikilink}"

    # for conditionals in templates
    @wikidata = true


  relocateClaims: (attrs)->
    claims = {}
    for id, claim of attrs.claims
      claims[id] = new Array
      # adding label as a non-enumerable value
      claims[id].label = _.i18n id
      if typeof claim is 'object'
        claim.forEach (statement)->
          switch statement.mainsnak.datatype
            when 'string'
              claims[id].push(statement._value = statement.mainsnak.datavalue.value)
            when 'wikibase-item'
              statement._id = statement.mainsnak.datavalue.value['numeric-id']
              claims[id].push "Q#{statement._id}"
            else claims[id].push(statement.mainsnak)
    @set 'claims', claims

  findAPicture: (attrs)->
    pictures = []

    if attrs.claims.P18?
      attrs.claims.P18.forEach (statement)->
        if statement?.datavalue?.value
          pictures.push _.wmCommonsThumb(statement.datavalue.value)
        else _.log statement, 'P18: missing value'

    @set 'pictures', pictures

    label = @get('label')

    isbn13 = _.stringOnly attrs.claims?.P957?[0]
    isbn10 = _.stringOnly attrs.claims?.P212?[0]
    isbn = isbn13 or isbn10
    if isbn? then isbn = books.normalizeIsbn(isbn)
    data = isbn || label

    if data?
      books.getImage(data)
      .then (res)=>
        if res?.image?
          pictures = @get('pictures')
          pictures.unshift res.image
          @set('pictures', pictures)
      .fail (err)-> _.log err, "err after bookAPI.getImage for #{data}"
      .done()

  getEntityValue: (attrs, props, lang)->
    if attrs[props]?[lang]?.value?
      return attrs[props][lang].value
    else if attrs[props]?.en?.value?
      return attrs[props].en.value
    else return

  getWikipediaInfo: (attrs, lang)->
    wikipedia = {}

    if title = @getWikipediaTitle(attrs.sitelinks, lang)
      wikipedia.title = title
      wikipedia.root = "https://#{lang}.wikipedia.org"
      wikipedia.url = "https://#{lang}.wikipedia.org/wiki/#{title}"
      wikipedia.mobileUrl = "https://#{lang}.m.wikipedia.org/wiki/#{title}"
    else if title = @getWikipediaTitle(attrs.sitelinks, lang)
      wikipedia.title = title
      wikipedia.url = "https:// en.wikipedia.org/wiki/#{title}"
      wikipedia.mobileUrl = "https://en.m.wikipedia.org/wiki/#{title}"
      wikipedia.root = "https://en.wikipedia.org"

    @set 'wikipedia', wikipedia

  getWikipediaTitle: (sitelinks, lang)->
    if sitelinks?["#{lang}wiki"]?.title?
      return sitelinks["#{lang}wiki"].title

  claimsLabels: ->
    claims = @get('claims')
    logs = []
    for k,v of claims
      logs.push [k, v.label]
    return logs