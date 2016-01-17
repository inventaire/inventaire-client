Entity = require './entity'
wd_ = require 'lib/wikidata'
wdBooks_ = require 'modules/entities/lib/wikidata/books'
wdAuthors_ = require 'modules/entities/lib/wikidata/books'
error_ = require 'lib/error'
images_ = require '../lib/images'

module.exports = Entity.extend
  # entities won't be saved to CouchDB and can keep their
  # initial API id
  idAttribute: 'id'
  prefix: 'wd'
  initialize: ->
    @initLazySave()
    @_updates = {}
    # _.log @status = @get('status'), 'status'

    # data that are @set don't need to be re-set when
    # the model was cached in Entities local/temporary collections
    unless @get('status')?.formatted

      # todo: make search only return ids and let the client fetch entities data
      # so that it can avoid overriding cached entities and re-fetch associated data (reverse claims, images...)
      if Entities.byUri('wd:#{@id}')?
        console.warn "reformatting #{@id} while it was already cached!
        Probably because the server returned fresh data (ex: during entity search)"

      { lang } = app.user

      @setWikiLinks lang
      @setWikipediaExtract lang
      # overriding sitelinks to make room when persisted to indexeddb
      @_updates.sitelinks = {}

      @rebaseClaims()
      @setAttributes @attributes, lang
      # depends on the freshly defined @_updates.claims
      @type = wd_.type @_updates
      @findAPicture()

      @set @_updates
      # @_updates isnt needed anymore
      @_updates = null

      # status might have been initialized by findAPicture
      @set 'status.formatted', true

      @save()

    # if waiters werent defined yet, they wont be fetched
    @waitForExtract ?= _.preq.resolve()
    @waitForPicture ?= _.preq.resolve()
    @waitForData = Promise.all [ @waitForExtract, @waitForPicture ]

    # data on models root aren't persisted so need to be set everytimes
    @claims = @get 'claims'
    # for conditionals in templates
    @wikidata = true

    @typeSpecificInitilize()

  rebaseClaims: ->
    claims = @get 'claims'
    if claims?
      claims = wdk.simplifyClaims claims
      # aliasing should happen after rebasing
      # as aliasing needs strings or numbers to test value uniqueness
      @_updates.claims = claims = wd_.aliasingClaims claims
      @setOriginalLang claims
    return

  setOriginalLang: (claims)->
    # P364: original language of work
    # P103: native language
    originalLangWdId = (claims.P364 or claims.P103)?[0]
    @originalLang = window.wdLang.byWdId[originalLangWdId]?.code
    return

  setAttributes: (attrs, lang)->
    pathname = "/entity/wd:#{@id}"
    @_updates.canonical = pathname

    label = getEntityValue attrs, 'labels', lang, @originalLang
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

    description = getEntityValue attrs, 'descriptions', lang, @originalLang
    if description?
      @_updates.description = description

    # reverseClaims: ex: this entity is a P50 of entities Q...
    @_updates.reverseClaims = {}
    return

  setWikiLinks: (lang)->
    @_updates.wikidata =
      url: "https://www.wikidata.org/entity/#{@id}"
      wiki: "https://www.wikidata.org/wiki/#{@id}"
    @_updates.uri = "wd:#{@id}"

    @originalLang = @_updates.claims?.P364?[0]
    sitelinks = @get 'sitelinks'
    if sitelinks?
      # required to fetch images from the English Wikipedia
      @enWpTitle = sitelinks.enwiki?.title
      @_updates.wikipedia = wd_.sitelinks.wikipedia sitelinks, lang

      @_updates.wikisource = wd_.sitelinks.wikisource sitelinks, lang

    return

  setWikipediaExtract: (lang)->
    title = @get('sitelinks')?["#{lang}wiki"]?.title
    if title?
      @waitForExtract = wd_.wikipediaExtract lang, title
      .then (extract)=>
        if extract?
          @set 'extract', extract
          @save()
      .catch _.Error('getWikipediaExtract err')
    return

  findAPicture: ->
    # initializing pictures array: should only be used
    # at first reception of the entity data
    @_updates.pictures = pictures = []
    @save()

    openLibraryId = @_updates.claims?.P648?[0]
    # P18 is expected to have only one value
    # but in cases it has several, we just pick one
    # as there is just one pictureCredits attribute.
    commonsImage = @_updates.claims?.P18?[0]
    @waitForPicture = @_pickBestPic openLibraryId, commonsImage

  _pickBestPic: (openLibraryId, commonsImage)->
    getters = {}
    if openLibraryId?
      getters.ol = images_.openLibrary.bind @, openLibraryId

    if commonsImage?
      getters.wm = images_.wmCommons.bind @, commonsImage

    if @enWpTitle?
      getters.wp = images_.enWikipedia.bind @, @enWpTitle

    # unless it's an author, in which case commons pictures are prefered
    # => gives access to photo credits
    if @type is 'human' then order = ['wm', 'wp', 'ol']
    # giving priority to openlibrary's pictures for books
    # as it has only covers while commons sometimes has just an illustration
    else order = ['ol', 'wp', 'wm']

    candidates = _.values _.pick(getters, order)
    if candidates.length is 0 then return _.preq.resolve()

    _.preq.fallbackChain candidates
    .then @_savePicture.bind(@)
    .catch _.Error('_pickBestPic err')

  _savePicture: (url)->
    _.log url, 'url'
    @push 'pictures', url
    @save()

  typeSpecificInitilize: ->
    switch @type
      when 'book' then @initializeBook()
      when 'human' then @initializeAuthor()

  initializeBook: ->
    wdBooks_.fetchAuthorsEntities(@)
    # need to be after authors entities were fetched to have authors names
    .then @findAPictureIfMissing.bind(@)
    .catch _.Error('fetchAuthorsEntities err')

  findAPictureIfMissing: ->
    @waitForPicture
    .then =>
      if @get('pictures').length is 0
        wdBooks_.findAPictureByBookData @

  initializeAuthor: ->

  # to be called by a view onShow:
  # updates the document with the entities data
  updateMetadata: ->
    @waitForData
    .then @executeMetadataUpdate.bind(@)
    .catch _.Error('updateMetadata err')

  executeMetadataUpdate: ->
    app.execute 'metadata:update',
      title: @findBestTitle()
      description: @findBestDescription()?[0..500]
      image: @get('pictures')?[0]
      url: @get 'canonical'

  findBestTitle: ->
    title = @get 'title'
    switch @type
      when 'human' then _.i18n 'books_by_author', {author: title}
      when 'book' then @buildBookTitle()
      else title

  findBestDescription: ->
    extract = @get('extract')
    description = @get('description')
    # dont use an extract too short as it will be
    # more of it's wikipedia source url than a description
    if extract? and extract.length > 300 then return extract
    else description or extract

getEntityValue = (attrs, props, lang, originalLang)->
  property = attrs[props]
  if property?
    order = getLangPriorityOrder lang, originalLang, property
    while order.length > 0
      nextLang = order.shift()
      value = property[nextLang]?.value
      if value? then return value

  return

getLangPriorityOrder = (lang, originalLang, property)->
  order = [ lang ]
  if originalLang? then order.push originalLang
  order.push 'en'
  availableLangs = Object.keys property
  return _.uniq order.concat(availableLangs)
