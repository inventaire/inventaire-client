ItemComments = require './item_comments'
ItemTransactions = require './item_transactions'
itemActions = require '../plugins/item_actions'
itemUpdaters = require '../plugins/item_updaters'

module.exports = Marionette.LayoutView.extend
  id: 'itemShowData'
  template: require './templates/item_show_data'
  regions:
    transactionsRegion: '#transactions'
    commentsRegion: '#comments'

  behaviors:
    ElasticTextarea: {}
    AlertBox: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @initPlugins()
    @uniqueSelector = '#'+@id
    # The alertbox is appended to the target's parent, which might have
    # historical reasons but seems a bit dumb now
    @alertBoxTarget = @uniqueSelector + ' .leftBox .panel'
    @listenTo @model, 'change', @lazyRender

  initPlugins: ->
    itemActions.call(@)
    itemUpdaters.call(@)

  onShow: ->
    setTimeout @preserveMinHeight.bind(@), 200

  # Allows to re-render without provoking a scroll jump because the view
  # suddenly takes less room vertically
  preserveMinHeight: ->
    # Add a margin to take in account details and notes form mode height
    minHeight = @$el.parent().height() + 30
    @$el.parent().css 'min-height', minHeight

  onRender: ->
    @showComments()
    app.execute 'foundation:reload'
    if app.user.loggedIn then @showTransactions()

  events:
    'click a#editDetails, a#cancelDetailsEdition': 'toggleDetailsEditor'
    'click a#validateDetails': 'validateDetails'
    'click a#editNotes, a#cancelNotesEdition': 'toggleNotesEditor'
    'click a#validateNotes': 'validateNotes'
    'click a.requestItem': -> app.execute 'show:item:request', @model

  serializeData: -> @model.serializeData()

  # itemDestroy is in item_updaters
  itemDestroyBack: -> app.execute 'show:item:modal', @model
  afterDestroy: -> app.execute 'show:home'

  toggleDetailsEditor: -> @toggleEditor('details')
  toggleNotesEditor: -> @toggleEditor('notes')

  validateDetails: -> @validateEdit('details')
  validateNotes: -> @validateEdit('notes')

  toggleEditor: (nameBase)->
    $("##{nameBase}").toggle()
    $("##{nameBase}Editor").toggle()

  validateEdit: (nameBase)->
    @toggleEditor(nameBase)
    edited = $("##{nameBase}Editor textarea").val()
    if edited isnt @model.get(nameBase)
      app.request 'item:update',
        item: @model
        attribute: nameBase
        value: edited
        selector: "##{nameBase}Editor"

  showComments:->
    @commentsRegion.show new ItemComments { @model }

  showTransactions: ->
    @transactions ?= app.request 'get:transactions:ongoing:byItemId', @model.id
    @transactionsRegion.show new ItemTransactions { collection: @transactions }

  afterDestroy: ->
    app.execute 'show:inventory:main:user'
