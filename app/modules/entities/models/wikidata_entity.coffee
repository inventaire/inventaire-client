Entity = require './entity'
wd = app.lib.wikidata
wdBooks_ = require 'modules/entities/lib/wikidata/books'
wdAuthors_ = require 'modules/entities/lib/wikidata/books'

module.exports = WikidataEntity = Entity.extend
  prefix: 'wd'
  initialize: ->
    @initLazySave()
    @updates = {}
    # _.log @status = @get('status'), 'status'

    # data that are @set don't need to be re-set when
    # the model was cached in Entities local/temporary collections
    unless @get('status')?.formatted
      _.log @get('title'), 'entity:formatting'

      # todo: make search only return ids and let the client fetch entities data
      # so that it can avoid overriding cached entities and re-fetch associated data (reverse claims, images...)
      if Entities.byUri('wd:#{id}')?
        console.warn "reformatting #{@id} while it was already cached! Probably because the server returned fresh data (ex: during entity search)"

      lang = app.user.lang

      @setAttributes(@attributes, lang)
      @rebaseClaims()
      @findAPicture()

      @setWikiLinks(lang)
      @getWikipediaExtract(lang)
      # overriding sitelinks to make room when persisted to indexeddb
      @updates.sitelinks = {}

      @set @updates

      # status might have been initialized by findAPicture
      @set 'status.formatted', true

      @save()



    # data on models root aren't persisted so need to be set everytimes
    @claims = @get 'claims'
    # for conditionals in templates
    @wikidata = true

    @typeSpecificInitilize()

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

    @originalLang = @updates.claims?.P364?[0]
    sitelinks = @get('sitelinks')
    if sitelinks?
      @updates.wikipedia = wd.sitelinks.wikipedia(sitelinks, lang)

      @updates.wikisource = wd.sitelinks.wikisource(sitelinks, lang)

  getWikipediaExtract: (lang)->
    title = @get('sitelinks')?["#{lang}wiki"]?.title
    if title?
      wd.wikipediaExtract(lang, title)
      .then (extract)=>
        _.log extract, "#{@get('label')} extract"
        if extract?
          @set 'description', extract
          @save()
      .catch _.Error('getWikipediaExtract err')


  findAPicture: ->
    # initializing pictures array: should only be used
    # at first reception of the entity data
    @updates.pictures = pictures = []
    @save()

    images = @updates.claims?.P18
    if images?
      images.forEach (title)=>
        wd.wmCommonsThumb(title, 1000)
        .then (url)=>
          pictures = @get('pictures') or []
          pictures.push url
          # async so can't be on the @updates bulk set
          @set 'pictures', pictures
          @save()

  upgrade: -> console.error new Error('upgrade method was removed')

  typeSpecificInitilize: ->
    type = wd.type(@)
    switch type
      when 'book' then @initializeBook()
      when 'human' then @initializeAuthor()

  initializeBook: ->
    wdBooks_.fetchAuthorsEntities(@)
    .then => wdBooks_.findAPictureByBookData(@)
    .catch (err)-> _.log(err, 'fetchAuthorsEntities err')

  initializeAuthor: ->

getEntityValue = (attrs, props, lang)->
  property = attrs[props]
  if property?
    if property[lang]?.value? then return property[lang].value
    else if property.en?.value? then return property.en.value
    else
      any = _.pickOne(property)?
      if any?.value? then any.value
  return
