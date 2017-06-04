forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
History = require './history'
MergeSuggestions = require './merge_suggestions'
Entities = require 'modules/entities/collections/entities'
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
    { pluralizedType } = @model
    uri = @model.get 'uri'
    _.preq.get app.API.entities.search @model.get('label'), false, true
    .get pluralizedType
    .then parseSearchResults(uri)
    .then (suggestions)=>
      collection = new Entities suggestions
      toEntity = @model
      @mergeSuggestion.show new MergeSuggestions { collection, toEntity }

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

parseSearchResults = (uri)-> (searchResults)->
  uris = _.pluck searchResults, 'uri'
  prefix = uri.split(':')[0]
  if prefix is 'wd' then uris = uris.filter isntWdUri
  # Omit the current entity URI
  uris = _.without uris, uri
  # Search results entities miss their claims, so we need to fetch the full entities
  return app.request 'get:entities:models', { uris }

isntWdUri = (uri)-> uri.split(':')[0] isnt 'wd'
