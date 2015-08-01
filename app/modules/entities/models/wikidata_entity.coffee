Entity = require './entity'
wd = app.lib.wikidata
wdBooks_ = require 'modules/entities/lib/wikidata/books'
wdAuthors_ = require 'modules/entities/lib/wikidata/books'

module.exports = Entity.extend
  prefix: 'wd'
  initialize: ->
    @initLazySave()
    @_updates = {}
    # _.log @status = @get('status'), 'status'

    # data that are @set don't need to be re-set when
    # the model was cached in Entities local/temporary collections
    unless @get('status')?.formatted
      _.log @get('title'), 'entity:formatting'

      # todo: make search only return ids and let the client fetch entities data
      # so that it can avoid overriding cached entities and re-fetch associated data (reverse claims, images...)
      if Entities.byUri('wd:#{id}')?
        console.warn "reformatting #{@id} while it was already cached!
        Probably because the server returned fresh data (ex: during entity search)"

      { lang } = app.user

      @setWikiLinks lang
      @getWikipediaExtract lang
      # overriding sitelinks to make room when persisted to indexeddb
      @_updates.sitelinks = {}

      @setAttributes @attributes, lang
      @rebaseClaims()
      @findAPicture()

      @set @_updates
      # @_updates isnt needed anymore
      @_updates = null

      # status might have been initialized by findAPicture
      @set 'status.formatted', true

      @save()

    # if @waitForExtract wasnt defined yet, it wont be fetched
    unless @waitForExtract? then @waitForExtract = _.preq.resolve()

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
    unless label?
      # if no label was found, try to use the wikipedia page title
      # remove the part between parenthesis
      label = @_updates.wikipedia?.title?.replace /\s\(\w+\)/, ''
    if label?
      @_updates.label = label
      @_updates.title = label
      pathname += "/" + _.softEncodeURI(label)

    @_updates.pathname = pathname
    @_updates.domain = 'wd'

    description = getEntityValue attrs, 'descriptions', lang
    if description?
      @_updates.description = description

    # reverseClaims: ex: this entity is a P50 of entities Q...
    @_updates.reverseClaims = {}

  rebaseClaims: ->
    claims = @get 'claims'
    if claims?
      # aliasing should happen after rebasing
      # as aliasing needs strings or numbers to test value uniqueness
      claims = wd.getRebasedClaims(claims)
      @_updates.claims = wd.aliasingClaims(claims)
    else console.warn 'no claims found', @

  setWikiLinks: (lang)->
    @_updates.wikidata =
      url: "https://www.wikidata.org/entity/#{@id}"
      wiki: "https://www.wikidata.org/wiki/#{@id}"
    @_updates.uri = "wd:#{@id}"

    @originalLang = @_updates.claims?.P364?[0]
    sitelinks = @get('sitelinks')
    if sitelinks?
      @_updates.wikipedia = wd.sitelinks.wikipedia(sitelinks, lang)

      @_updates.wikisource = wd.sitelinks.wikisource(sitelinks, lang)

  getWikipediaExtract: (lang)->
    title = @get('sitelinks')?["#{lang}wiki"]?.title
    if title?
      @waitForExtract = wd.wikipediaExtract(lang, title)
      .then (extract)=>
        if extract?
          @set 'extract', extract
          @save()
      .catch _.Error('getWikipediaExtract err')

  findAPicture: ->
    # initializing pictures array: should only be used
    # at first reception of the entity data
    @_updates.pictures = pictures = []
    @save()

    images = @_updates.claims?.P18
    if images?
      images.forEach (title)=>
        wd.wmCommonsThumb(title, 1000)
        .then (url)=>
          pictures = @get('pictures') or []
          pictures.push url
          # async so can't be on the @_updates bulk set
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
    # need to be after authors entities were fetched to have authors names
    .then wdBooks_.findAPictureByBookData.bind(null, @)
    .catch _.Error('fetchAuthorsEntities err')

  initializeAuthor: ->

  # to be called by a view onShow:
  # updates the document with the entities data
  updateTwitterCard: ->
    @waitForExtract
    .then @executeTwitterCardUpdate.bind(@)
    .catch _.Error('updateTwitterCard err')

  executeTwitterCardUpdate: ->
    app.execute 'metadata:update',
      title: @get('title')
      description: @findBestDescription()?[0..500]
      image: @get('pictures')?[0]

  findBestDescription: ->
    extract = @get('extract')
    description = @get('description')
    # dont use an extract too short as it will be
    # more of it's wikipedia source url than a description
    if extract? and extract.length > 300 then return extract
    else description or extract

getEntityValue = (attrs, props, lang)->
  property = attrs[props]
  if property?
    if property[lang]?.value? then return property[lang].value
    else if property.en?.value? then return property.en.value
    else
      any = _.pickOne(property)?
      if any?.value? then any.value
  return
