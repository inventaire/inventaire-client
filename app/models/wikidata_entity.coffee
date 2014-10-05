books = require 'lib/books'

module.exports = class WikidataEntity extends Backbone.NestedModel
  initialize: (entityData)->
    lang = app.user.lang
    @setAttributes(@attributes, lang)
    @relocateClaims(@attributes)
    @getWikipediaInfo(@attributes, lang)
    @findAPicture()

  # entities won't be saved to CouchDB and can keep their
  # initial API id
  idAttribute: 'id'
  setAttributes: (attrs, lang)->
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

    # reverseClaims: this entity is a P50 of entities Q...
    @set 'reverseClaims', {}


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
    @claims = claims

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

  findAPicture: ->
    pictures = []

    if @claims?.P18?
      @claims.P18.forEach (statement)->
        if statement?.datavalue?.value
          pictures.push _.wmCommonsThumb(statement.datavalue.value)
        else _.log statement, 'P18: missing value'

    @set 'pictures', pictures

  upgrade: (type)->
    switch type
      when 'book' then upgrader = app.Model.BookWikidataEntity
      when 'author' then upgrader = app.Model.AuthorWikidataEntity

    _.extend @, upgrader.prototype
    if @specificInitializers? then @specificInitializers()

    return @