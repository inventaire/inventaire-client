forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
History = require './history'
mergeEntities = require './lib/merge_entities'

module.exports = Marionette.LayoutView.extend
  template: require './templates/admin_section'

  behaviors:
    PreventDefault: {}
    AlertBox: {}
    Loading: {}

  regions:
    history: '#history'
    mergeSuggestion: '#merge-suggestion'

  ui:
    mergeWithInput: '#mergeWithField'
    historyTogglers: '#historyToggler i.fa'

  initialize: ->
    @_historyShown = false

  serializeData: ->
    canBeMerged: @canBeMerged()
    mergeWith: mergeWithData()
    isAnEdition: @model.type is 'edition'

  events:
    'click #mergeWithButton': 'merge'
    'click #showMergeSuggestions': 'showMergeSuggestions'
    'click #historyToggler': 'toggleHistory'

  canBeMerged: ->
    if @model.type isnt 'edition' then return true
    # Editions that have no ISBN can be merged
    if not @model.get('claims.wdt:P212')? then return true
    return false

  showMergeSuggestions: ->
    app.execute 'show:merge:suggestions', { region: @mergeSuggestion, @model }

  merge: (e)->
    behaviorsPlugin.startLoading.call @, '#mergeWithButton'

    fromUri = @model.get 'uri'
    toUri = @ui.mergeWithInput.val()

    mergeEntities fromUri, toUri
    .then app.Execute('show:entity:from:model')
    .catch error_.Complete('#mergeWithField', false)
    .catch forms_.catchAlert.bind(null, @)

  showHistory: ->
    @model.fetchHistory()
    .then => @history.show new History { collection: @model.history }

  toggleHistory: ->
    unless @history.hasView() then @showHistory()
    @history.$el.toggleClass 'hidden'
    @ui.historyTogglers.toggle()

mergeWithData = ->
  nameBase: 'mergeWith'
  field:
    placeholder: 'ex: wd:Q237087'
    dotdotdot: ''
  button:
    text: _.I18n 'merge'
    classes: 'light-blue bold postfix'
