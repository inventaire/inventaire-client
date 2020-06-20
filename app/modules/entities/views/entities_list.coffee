loader = require 'modules/general/views/templates/loader'
error_ = require 'lib/error'
canAddOneTypeList = [ 'serie', 'work', 'edition', 'collection' ]
EntitiesListAdder = require './entities_list_adder'
{ currentRoute } = require 'lib/location'

# TODO:
# - deduplicate series in sub series https://inventaire.io/entity/wd:Q740062
# - hide series parts when displayed as sub-series

module.exports = Marionette.CompositeView.extend
  template: require './templates/entities_list'
  className: ->
    standalone = if @options.standalone then 'standalone' else ''
    return "entitiesList #{standalone}"
  behaviors:
    Loading: {}
    PreventDefault: {}

  childViewContainer: '.container'
  tagName: -> if @options.type is 'edition' then 'ul' else 'div'

  getChildView: (model)->
    { type } = model
    switch type
      when 'serie' then require './serie_layout'
      when 'work' then require './work_li'
      when 'article' then require './article_li'
      # Types included despite not being works
      # to make this view reusable by ./claim_layout with those types.
      # This view should thus possibily be renamed entities_list
      when 'edition' then require './edition_li'
      when 'human' then require './author_layout'
      when 'publisher' then require './publisher_layout'
      when 'collection' then require './collection_layout'
      else
        err = error_.new "unknown entity type: #{type}", model
        # Weird: errors thrown here don't appear anyware
        # where are those silently catched?!?
        console.error 'entities_list getChildView err', err, model
        throw err

  childViewOptions: (model, index)->
    refresh: @options.refresh
    showActions: @options.showActions
    wrap: @options.wrapWorks
    compactMode: @options.compactMode

  ui:
    counter: '.counter'
    more: '.displayMore'
    addOne: '.addOne'
    moreCounter: '.displayMore .counter'

  initialize: ->
    { @parentModel } = @options
    initialLength = @options.initialLength or 5
    @batchLength = @options.batchLength or 15

    @fetchMore = @collection.fetchMore.bind @collection
    @more = @collection.more.bind @collection

    @collection.firstFetch initialLength

  serializeData: ->
    title: @options.title
    customTitle: @options.customTitle
    hideHeader: @options.hideHeader
    more: @more()
    totalLength: @collection.totalLength
    addOneLabel: addOneLabels[@parentModel.type][@options.type]

  events:
    'click a.displayMore': 'displayMore'
    'click a.addOne': 'addOne'

  displayMore: ->
    @startMoreLoading()

    @collection.fetchMore @batchLength
    .then =>
      if @more()
        @ui.moreCounter.text @more()
      else
        @ui.more.hide()
        @ui.addOne.removeClass 'hidden'

  startMoreLoading: ->
    @ui.moreCounter.html loader()

  addOne: ->
    unless app.request 'require:loggedIn', currentRoute() then return
    { type, parentModel } = @options
    header = addOneLabels[@parentModel.type][@options.type]
    app.layout.modal.show new EntitiesListAdder { header, type, parentModel, listCollection: @collection }

addOneLabels =
  # parent model type
  human:
    # list elements type
    work: 'add a work from this author'
    serie: 'add a serie from this author'
  serie:
    work: 'add a work to this serie'
  publisher:
    edition: 'add an edition from this publisher'
    collection: 'add a collection from this publisher'
  collection:
    edition: 'add an edition to this collection'
