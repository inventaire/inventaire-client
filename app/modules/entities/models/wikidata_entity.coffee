Entity = require './entity'
wdk = require 'wikidata-sdk'
wd_ = require 'lib/wikimedia/wikidata'
sitelinks_ = require 'lib/wikimedia/sitelinks'
wikipedia_ = require 'lib/wikimedia/wikipedia'
aliasClaims = require 'lib/wikimedia/alias_claims'
wdBooks_ = require 'modules/entities/lib/wikidata/books'
wdAuthors_ = require 'modules/entities/lib/wikidata/books'
error_ = require 'lib/error'
images_ = require '../lib/images'
getBestLangValue = require '../lib/get_best_lang_value'

module.exports = Entity.extend
  # entities won't be saved to CouchDB and can keep their
  # initial API id
  idAttribute: 'id'
  prefix: 'wd'
  initialize: ->
    @initLazySave()

    @formatIfNew()

    # if waiters werent defined yet, they wont be fetched
    @waitForExtract ?= _.preq.resolved
    @waitForPicture ?= _.preq.resolved
    @waitForData = Promise.all [ @waitForExtract, @waitForPicture ]

    @typeSpecificInitilize()

  formatSync: ->
    # Gathering updates to set them all at once and trigger only one change event:
    # to be used only in formatSync sub methods
    @_updates = {}
    # todo: make search only return ids and let the client fetch entities data
    # so that it can avoid overriding cached entities and re-fetch associated data (reverse claims, images...)
    if app.entities.byUri('wd:#{@id}')?
      console.warn "reformatting #{@id} while it was already cached!
      Probably because the server returned fresh data (ex: during entity search)"

    { lang } = app.user

    @setWikiLinks lang
    @setWikipediaExtract lang
    # overriding sitelinks to make room when persisted to indexeddb
    @_updates.sitelinks = {}
    # will be populated by findPictures
    @_updates.pictures = []

    @rebaseClaims()
    @setAttributes @attributes, lang
    # depends on the freshly defined @_updates.claims
    @type = wd_.type @_updates

    # Setting all those updates at once
    @set @_updates
    # @_updates isnt needed anymore
    @_updates = null

  formatAsync: ->
    @findAPicture()

  afterFormatSync: ->
    @claims = @get 'claims'

  rebaseClaims: ->
    claims = @get 'claims'
    if claims?
      claims = wd_.formatClaims claims
      # Aliasing should happen after rebasing
      # as aliasing needs simplified values (strings, numbers, etc) to test value uniqueness
      @_updates.claims = claims = aliasClaims claims
      @originalLang = wd_.getOriginalLang claims

      publicationDate = claims['wdt:P577']?[0]
      if publicationDate?
        @publicationYear = getYearFromEpoch publicationDate
    return

  setAttributes: (attrs, lang)->
    @_updates.canonical = @_updates.pathname = "/entity/wd:#{@id}"

    label = getEntityValue attrs, 'labels', lang, @originalLang
    unless label?
      # if no label was found, try to use the wikipedia page title
      # remove the escaped spaces: %20
      label = decodeURIComponent @_updates.wikipedia?.title
      # remove the part between parenthesis
      label = label?.replace /\s\(\w+\)/, ''
    if label?
      @_updates.label = label
      @_updates.title = label

    description = getEntityValue attrs, 'descriptions', lang, @originalLang
    if description?
      @_updates.description = description

    # reverseClaims: ex: this entity is a P50 of entities Q...
    @_updates.reverseClaims = {}
    return

  setWikiLinks: (lang)->
    @_updates.editable =
      url: "https://www.wikidata.org/entity/#{@id}"
      wiki: "https://www.wikidata.org/wiki/#{@id}"
      wikidata: true
    @_updates.uri = "wd:#{@id}"

    @originalLang = @_updates.claims?['wdt:P364']?[0]
    sitelinks = @get 'sitelinks'
    if sitelinks?
      # required to fetch images from the English Wikipedia
      @enWpTitle = sitelinks.enwiki?.title
      @_updates.wikipedia = sitelinks_.wikipedia sitelinks, lang

      @_updates.wikisource = sitelinks_.wikisource sitelinks, lang

    return

  setWikipediaExtract: (lang)->
    title = @get('sitelinks')?["#{lang}wiki"]?.title
    if title?
      @waitForExtract = wikipedia_.extract lang, title
      .then (extract)=>
        if extract?
          @set 'extract', extract
          @save()
      .catch _.Error('setWikipediaExtract err')
    return

  findAPicture: ->
    openLibraryId = @claims?['wdt:P648']?[0]
    # P18 is expected to have only one value
    # but in cases it has several, we just pick one
    # as there is just one pictureCredits attribute.
    commonsImage = @claims?['wdt:P18']?[0]
    @waitForPicture = @_pickBestPic openLibraryId, commonsImage

  _pickBestPic: (openLibraryId, commonsImage)->
    getters = {}
    if openLibraryId?
      getters.ol = images_.openLibrary.bind @, openLibraryId

    if commonsImage?
      getters.wm = images_.wmCommons.bind @, commonsImage

    if @enWpTitle?
      getters.wp = images_.enWikipedia.bind @, @enWpTitle

    order = @_getPicSourceOrder()

    candidates = _.values _.pick(getters, order)
    if candidates.length is 0 then return _.preq.resolved

    _.preq.fallbackChain candidates
    .then @_savePicture.bind(@)
    .catch _.Error('_pickBestPic err')

  _getPicSourceOrder: ->
    switch @type
      # commons pictures are prefered to Open Library
      # to get access to photo credits
      when 'human' then return ['wm', 'ol', 'wp']
      when 'genre' then return ['wm', 'wp']
      # giving priority to openlibrary's pictures for books
      # as it has only covers while commons sometimes has just an illustration
      else
        # Give priority to Wikimedia over Wikipedia for books
        # likely to be in the public domain and have a good image set in Wikidata
        # while querying images from English Wikipedia articles
        # can be quite random results
        if @publicationYear? and @publicationYear < yearsAgo(70)
          return ['ol', 'wm', 'wp']
        else
          return ['ol', 'wp', 'wm']

  _savePicture: (url)->
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

  getAuthorsString: ->
    unless @claims?['wdt:P50']?.length > 0 then return _.preq.resolve ''
    uris = @claims['wdt:P50']
    return wd_.getLabel uris, app.user.lang

getEntityValue = (attrs, props, lang, originalLang)->
  property = attrs[props]
  if property?
    value = getBestLangValue lang, originalLang, property
    if value?.value? then return value.value

  return

getYearFromEpoch = (epochTime)-> new Date(epochTime).getYear() + 1900
yearsAgo = (years)-> new Date().getYear() + 1900 - years
