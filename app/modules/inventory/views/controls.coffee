module.exports = Marionette.ItemView.extend
  template: require './templates/controls'
  className: 'controls'
  ui:
    filter: 'input.filter'
    layoutTogglers: '.layouts a'
    cascade: '.cascade'
    grid: '.grid'

  serializeData: ->
    transactions: @transactionsData()

  transactionsData: ->
    _.values Items.transactions
    .map (transaction)->
      { label } = transaction
      transaction.title = "show/hide \"#{label}\" books"
      return transaction

  events:
    'keyup input.filter': 'filterItems'
    'click .cascade': 'displayCascade'
    'click .grid': 'displayGrid'
    'click .showControls': 'toggleControls'
    'click a.transaction': 'toggleTransaction'

  initialize: -> @lastFilter = null
  onRender: ->
    @setActiveLayout()
    @recoverControls()

  setActiveLayout: (layout)->
    @ui.layoutTogglers.removeClass 'active'
    layout = layout or app.request 'inventory:layout'
    @ui[layout].addClass 'active'

  displayCascade: ->
    app.vent.trigger 'inventory:layout:change', 'cascade'
    @setActiveLayout 'cascade'

  displayGrid: ->
    app.vent.trigger 'inventory:layout:change', 'grid'
    @setActiveLayout 'grid'

  filterItems: ->
    text = @ui.filter.val()
    if text isnt @lastFilter
      @lastFilter = text
      app.execute 'filter:items:byText', text, false

  toggleControls: ->
    if @$el.hasClass 'displayed' then @wrapControls()
    else @displayControls()

  recoverControls: ->
    # boolean arrives as a string, thus the need to use JSON.parse
    bool = JSON.parse localStorageProxy.getItem('controls:display')
    if bool then @displayControls() else @wrapControls()

  displayControls: ->
    @$el.addClass 'displayed'
    localStorageProxy.setItem 'controls:display', true

  wrapControls: ->
    @$el.removeClass 'displayed'
    localStorageProxy.setItem 'controls:display', false

  toggleTransaction: (e)->
    classes = e.currentTarget.attributes.class.value.split(' ')
    # the transaction name will be the first class
    transac = classes[0]
    if 'active' in classes
      $(e.currentTarget).removeClass 'active'
      app.execute 'filter:inventory:transaction:exclude', transac
    else
      $(e.currentTarget).addClass 'active'
      app.execute 'filter:inventory:transaction:include', transac
