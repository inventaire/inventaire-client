{ buildPath } = require 'lib/location'
EntitiesListElementCandidate = require './entities_list_element_candidate'

module.exports = Marionette.CompositeView.extend
  id: 'entitiesListAdder'
  template: require './templates/entities_list_adder'
  childViewContainer: '.entitiesListElementCandidates'
  childView: EntitiesListElementCandidate
  childViewOptions: ->
    parentModel: @options.parentModel
    listCollection: @options.listCollection

  initialize: ->
    { @type, @parentModel } = @options
    @setEntityCreationData()
    @collection = new Backbone.Collection()
    @addCandidates()

  serializeData: ->
    parent: @parentModel.toJSON()
    header: @options.header
    createPath: @createPath

  onShow: -> app.execute 'modal:open'

  events:
    'click .create': 'create'

  setEntityCreationData: ->
    { parentModel } = @
    { type: parentType } = parentModel

    claims = {}
    prop = parentModel.childrenClaimProperty
    claims[prop] = [ parentModel.get('uri') ]

    if parentType is 'serie'
      claims['wdt:P50'] = parentModel.get 'claims.wdt:P50'

    else if parentType is 'collection'
      claims['wdt:P123'] = parentModel.get 'claims.wdt:P123'

    href = buildPath '/entity/new', { @type, claims }

    @createPath = href
    @_entityCreationData = { @type, claims }

  addCandidates: ->
    unless @parentModel.getChildrenCandidatesUris? then return

    @parentModel.getChildrenCandidatesUris()
    .then _.Log('childrenCandidatesUris')
    .then (uris)-> app.request 'get:entities:models', { uris }
    .then @collection.add.bind(@collection)

  create: (e)->
    if _.isOpenedOutside e then return
    app.execute 'show:entity:create', @_entityCreationData
    app.execute 'modal:close'
