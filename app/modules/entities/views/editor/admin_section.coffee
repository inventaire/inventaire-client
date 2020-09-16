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
    @showHistorySection = app.user.hasAdminAccess

  serializeData: ->
    canBeMerged: @canBeMerged()
    mergeWith: mergeWithData()
    isAnEdition: @model.type is 'edition'
    isWikidataEntity: @model.get 'isWikidataEntity'
    wikidataEntityHistoryHref: @model.get 'wikidata.history'
    showHistorySection: @showHistorySection

  events:
    'click #mergeWithButton': 'merge'
    'click .deleteEntity': 'deleteEntity'
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
    .then => @history.show new History { @model }

  toggleHistory: ->
    unless @history.hasView() then @showHistory()
    @history.$el.toggleClass 'hidden'
    @ui.historyTogglers.toggle()

  deleteEntity: ->
    app.execute 'ask:confirmation',
      confirmationText: 'do you really want to delete stuff'
      action: @_deleteEntity.bind(@)

  _deleteEntity: ->
    uri = @model.get('invUri')
    _.preq.post app.API.entities.delete, { uris: [ uri ] }
    .then -> app.execute 'show:entity:edit', uri
    .catch displayDeteEntityErrorContext.bind(@)

mergeWithData = ->
  nameBase: 'mergeWith'
  field:
    placeholder: 'ex: wd:Q237087'
    dotdotdot: ''
  button:
    text: _.I18n 'merge'
    classes: 'light-blue bold postfix'

displayDeteEntityErrorContext = (err)->
  { context } = err.responseJSON
  if context
    console.log 'context', context
    claims = if context.claim? then [ context.claim ] else context.claims
    if claims?
      contextText = claims.map(buildClaimLink).join('')
      err.richMessage = "#{err.message}: <ul>#{contextText}</ul>"

  error_.complete err, '.delete-alert', false
  # Display the alertbox on the admin_section view
  forms_.catchAlert @, err

  # Rethrow the error to let the confirmation modal display a fail status
  throw err

buildClaimLink = (claim)->
  "<li><a href='/entity/#{claim.entity}/edit' class='showEntityEdit'>#{claim.property} - #{claim.entity}</a></li>"
