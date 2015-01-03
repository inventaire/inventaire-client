BookWikidataEntity = require './book_wikidata_entity'
AuthorWikidataEntity = require './author_wikidata_entity'
wd = app.lib.wikidata

module.exports = class WikidataEntity extends Backbone.NestedModel
  localStorage: new Backbone.LocalStorage 'wd:Entities'
  initialize: ->
    @updates = {}
    @status = @get('status')

    # data that are @set don't need to be re-set when
    # the model was cached in Entities local/temporary collections
    unless @status?.formatted

      # todo: make search only return ids and let the client fetch entities data
      # so that it can avoid overriding cached entities and re-fetch associated data (reverse claims, images...)
      if Entities.byUri('wd:#{id}')?
        console.warn "reformatting #{@id} while it was already cached! Probably because the server returned fresh data (ex: during entity search)"

      lang = app.user.lang

      @setAttributes(@attributes, lang)
      @rebaseClaims()
      @setWikiLinks(lang)
      @findAPicture()

      @updates.status = @status = {formatted: true}

      @set @updates
      @save()



    # data on models root aren't persisted so need to be set everytimes
    @claims = @get 'claims'
    # for conditionals in templates
    @wikidata = true


    # get type-specific methods
    # useful for specific models generated through this generalist model
    @upgrade()

  # method to override for upgraders models
  # Undefined on this basic model
    @specificInitializers()  if @specificInitializers?

  # entities won't be saved to CouchDB and can keep their
  # initial API id
  idAttribute: 'id'
  setAttributes: (attrs, lang)->
    pathname = "/entity/wd:#{@id}"

    label = getEntityValue attrs, 'labels', lang
    if label?
      @updates.label = label
      @updates.title = label
      pathname += "/" + _.softEncodeURI(label)

    @updates.pathname = pathname

    description = getEntityValue attrs, 'descriptions', lang
    if description?
      @updates.description = description

    # reverseClaims: ex: this entity is a P50 of entities Q...
    @updates.reverseClaims = {}

  rebaseClaims: ->
    claims = @get 'claims'
    if claims?
      claims = wd.aliasingClaims(claims)
      @updates.claims = wd.getRebasedClaims(claims)
    else console.warn 'no claims found', @

  setWikiLinks: (lang)->
    @updates.wikidata = {url: "http://www.wikidata.org/entity/#{@id}"}
    @updates.uri = "wd:#{@id}"

    @originalLang = @updates.claims.P364?[0]
    sitelinks = @get('sitelinks')
    if sitelinks?
      @updates.wikipedia = wd.sitelinks.wikipedia(sitelinks, lang)

      @updates.wikisource = wd.sitelinks.wikisource(sitelinks, lang)

    # overriding sitelinks to make room
    @updates.sitelinks = {}

  findAPicture: ->
    @updates.pictures = pictures = []
    @save()

    images = @updates.claims.P18
    if images?
      images.forEach (title)=>
        wd.wmCommonsThumb(title, 1000)
        .then (url)=>
          pictures = @get('pictures') or []
          pictures.push url
          # async so can't be on the @updates bulk set
          @set 'pictures', pictures
          @save()

  upgrade: ->
    type = wd.type(@)
    switch type
      when 'book' then upgrader = BookWikidataEntity
      when 'human' then upgrader = AuthorWikidataEntity

    if upgrader?
      proto = upgrader.prototype
      methodsNames = proto.upgradeProperties
      if methodsNames?.length > 0
        # just take explicitly listed methods to
        # avoid to load the model own methods
        # with Backbone.Model.prototype ones
        methods = _.pick(proto, methodsNames)
        _.extend @, methods
    return @

getEntityValue = (attrs, props, lang)->
  property = attrs[props]
  if property?
    if property[lang]?.value? then return property[lang].value
    else if property.en?.value? then return property.en.value
    else
      any = _.pickOne(property)?
      if any?.value? then any.value
  return