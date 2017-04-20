spinner = _.icon 'circle-o-notch', 'fa-spin'
error_ = require 'lib/error'
canAddOneTypeList = [ 'serie', 'work' ]

# TODO:
# - deduplicate series in sub series https://inventaire.io/entity/wd:Q740062
# - hide seris parts when displayed as sub-series

module.exports = Marionette.CompositeView.extend
  template: require './templates/works_list'
  className: 'worksList'
  behaviors:
    Loading: {}
    PreventDefault: {}

  childViewContainer: '.container'
  getChildView: (model)->
    { type } = model
    switch type
      when 'serie' then require './serie_layout'
      when 'work' then require './work_li'
      when 'article' then require './article_li'
      else
        err = error_.new "unknown work type: #{type}", model
        # Weird: errors thrown here don't appear anyware
        # where are those silently catched?!?
        console.error 'works_list getChildView err', err, model
        throw err

  childViewOptions: (model, index)->
    refresh: @options.refresh

  ui:
    counter: '.counter'
    more: '.displayMore'
    addOne: '.addOne'
    moreCounter: '.displayMore .counter'

  initialize: ->
    initialLength = @options.initialLength or 5
    @batchLength = @options.batchLength or 15

    @fetchMore = @collection.fetchMore.bind @collection
    @more = @collection.more.bind @collection

    # First fetch
    @collection.firstFetch initialLength

    @setEntityCreationData()

    if @options.type in canAddOneTypeList
      @addOneData =
        label: addOneLabels[@options.parentModel.type][@options.type]
        href: @_entityCreationData.href

  setEntityCreationData: ->
    { type, parentModel } = @options
    { type:parentType } =  parentModel

    claims = {}
    prop = parentModel.childrenClaimProperty
    claims[prop] = [ parentModel.get('uri') ]

    if parentType is 'serie'
      claims['wdt:P50'] = parentModel.get 'claims.wdt:P50'

    href = _.buildPath '/entity/new', { type, claims }

    @_entityCreationData = { type, claims, href }

  serializeData: ->
    title: @options.title
    hideHeader: @options.hideHeader
    more: @more()
    canRefreshData: true
    totalLength: @collection.totalLength
    addOne: @addOneData

  events:
    'click a.displayMore': 'displayMore'
    'click a.addOne': 'addOne'

  displayMore: ->
    @startMoreLoading()

    @collection.fetchMore @batchLength
    .then =>
      @ui.moreCounter.removeClass 'spinning'
      if @more()
        @ui.moreCounter.text @more()
      else
        @ui.more.hide()
        @ui.addOne.removeClass 'hidden'

  startMoreLoading: ->
    @ui.moreCounter
    .addClass 'spinning'
    .html spinner

  addOne: (e)->
    unless _.isOpenedOutside e
      { type, claims } = @_entityCreationData
      app.execute 'show:entity:create', { type, claims }

addOneLabels =
  # parent model type
  human:
    # list elements type
    work: 'add a work from this author'
    serie: 'add a serie from this author'
  serie:
    work: 'add a work to this serie'
