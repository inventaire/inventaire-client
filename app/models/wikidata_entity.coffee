module.exports = class WikidataEntity extends Backbone.NestedModel
  initialize: (entityData)->
    lang = app.user.lang
    @setAttributes(@attributes, lang)

    # data that are @set don't need to be re-set when
    # the model was cached in Entities local/temporary collections
    unless @get('status') is 'reformatted'
      @relocateClaims(@attributes)
      @getWikipediaInfo(@attributes, lang)
      @findAPicture()

    @specificInitializers()

    @set 'status', 'reformatted'

  # method to override for sub-models
  specificInitializers: ->
    # get type-specific methods
    # useful for specific models generated through this generalist model
    @type = wd.type(@)
    @upgrade(@type)

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

    # for conditionals in templates
    @wikidata = true
    @set 'wikidata', {url: "http://www.wikidata.org/entity/#{@id}"}
    @set 'uri', "wd:#{@id}"

    if description = @getEntityValue attrs, 'descriptions', lang
      @set 'description', description


    # reverseClaims: this entity is a P50 of entities Q...
    @set 'reverseClaims', {}

  relocateClaims: (attrs)->
    claims = {}
    for id, claim of attrs.claims
      claims[id] = []
      # adding label as a non-enumerable value
      # needed app.polyglot to be ready
      if app.polyglot? then claims[id].label = _.i18n(id)
      if _.isObject claim
        claim.forEach (statement)->
          # will be overriden at the end of this method
          # so won't be accessible on persisted models
          # testing existance shouldn't be needed thank to the status test
          # but let's keep it for now
          if statement?.mainsnak?.datatype?
            switch statement.mainsnak.datatype
              when 'string'
                claims[id].push(statement._value = statement.mainsnak.datavalue.value)
              when 'wikibase-item'
                statement._id = statement?.mainsnak?.datavalue.value['numeric-id']
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
    if title = @getWikipediaTitle(attrs.sitelinks, lang)
      wikipedia = @getWikipediaLinks(title, lang)
    else if title = @getWikipediaTitle(attrs.sitelinks, 'en')
      wikipedia = @getWikipediaLinks(title, 'en')

    if wikipedia? then @set 'wikipedia', wikipedia

  getWikipediaTitle: (sitelinks, lang)->
    if sitelinks?["#{lang}wiki"]?.title?
      return sitelinks["#{lang}wiki"].title

  getWikipediaLinks: (title, lang)->
    wikipedia =
      title: title
      root: "https://#{lang}.wikipedia.org"
      url: "https://#{lang}.wikipedia.org/wiki/#{title}"
      mobileUrl: "https://#{lang}.m.wikipedia.org/wiki/#{title}"

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

    if upgrader?
      proto = upgrader.prototype
      _.extend @, proto
      if proto.specificInitializers?
        proto.specificInitializers.call @

    return @