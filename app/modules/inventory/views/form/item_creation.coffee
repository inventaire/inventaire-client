EntityDataOverview = require 'modules/entities/views/entity_data_overview'
zxing = require 'modules/inventory/lib/scanner/zxing'
{ listingsData, transactionsData, getSelectorData } = require 'modules/inventory/lib/item_creation'
ItemCreationSelect = require 'modules/inventory/behaviors/item_creation_select'
error_ = require 'lib/error'
forms_ = require 'modules/general/lib/forms'

module.exports = Marionette.LayoutView.extend
  template: require './templates/item_creation'
  className: 'addEntity'
  regions:
    entityRegion: '#entity'
  behaviors:
    ElasticTextarea: {}
    ItemCreationSelect:
      behaviorClass: ItemCreationSelect
    AlertBox: {}

  ui:
    transaction: '#transaction'
    listing: '#listing'
    details: '#details'
    notes: '#notes'

  initialize: ->
    { @entity } = @options
    @_lastAddMode = app.request 'last:add:mode:get'

  onShow: ->
    @selectTransaction()
    @selectListing()
    @showEntityData()

  onDestroy: ->
    # waiting for the page to be closed to have the best guess
    # on the chosen listing and transaction mode
    listing = @model.get 'listing'
    transaction = @model.get 'transaction'

  selectTransaction: -> @selectButton 'transaction'
  selectListing: -> @selectButton 'listing'
  selectButton: (attr)->
    value = @model.get attr
    if value?
      $el = @ui[attr].find "a[id=#{value}]"
      if $el.length is 1
        @ui[attr].find('a').removeClass 'active'
        $el.addClass 'active'

  serializeData: ->
    title = @entity.get 'label'
    attrs =
      title: title
      listings: listingsData()
      transactions: transactionsData()
      header: _.i18n 'add_item_text', { title }

    return _.extend attrs, @addNextData()

  addNextData: ->
    data = {}
    if @_lastAddMode is 'scan:zxing' then data.zxing = zxing
    return data

  events:
    'click #transaction': 'updateTransaction'
    'click #listing': 'updateListing'
    'click #cancel': 'destroyItem'
    'click #validate': 'validateSimple'
    'click #validateAndAddNext': 'validateAndAddNext'

  showEntityData: ->
    @entityRegion.show new EntityDataOverview { model: @entity }

  # TODO: update the UI for update errors
  updateTransaction: ->
    transaction = getSelectorData @, 'transaction'
    app.execute 'last:transaction:set', transaction
    @updateItem { transaction }

  updateListing: ->
    listing = getSelectorData @, 'listing'
    app.execute 'last:listing:set', listing
    @updateItem { listing }

  updateDetails: -> @updateTextAttribute 'details'
  updateNotes: -> @updateTextAttribute 'notes'
  updateTextAttribute: (attr)->
    _.log arguments, 'updateTextAttribute'
    val = @ui[attr].val()
    update = {}
    update[attr] = val
    @updateItem update

  validateSimple: ->
    @validateItem()
    .then -> app.execute 'show:inventory:main:user'

  validateAndAddNext: ->
    @validateItem()
    .then @addNext.bind(@)

  _catchAlert: (err)->
    err.selector = '.panel'
    forms_.catchAlert @, err

  addNext: ->
    switch @_lastAddMode
      when 'search' then app.execute 'show:add:layout:search:last'
      when 'scan:embedded' then app.execute 'show:scanner:embedded'
      # If _lastAddMode is scan:zxing, the scanner should have been opened
      # by the click on the <a href=zxing.url>, which should open a new window
      # 'scan' is here as legacy
      when 'scan', 'scan:zxing' then return
      else
        _.warn @_lastAddMode, 'unknown or obsolete add mode'
        app.execute 'show:add:layout'

  validateItem: ->
    @updateItem
      details: @ui.details.val()
      notes: @ui.notes.val()
    .catch @_catchAlert.bind(@)

  updateItem: (data)->
    app.request 'item:update',
      item: @model
      data: data
    .catch @_catchAlert.bind(@)

  destroyItem: ->
    _.log 'item creation cancelled: destroying item'
    @model.destroy()
    .then _.Log('item destroyed')
    .then ->
      if Backbone.history.last.length > 0 then window.history.back()
      else app.execute 'show:home'
    .catch @_catchAlert.bind(@)
