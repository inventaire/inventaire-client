forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
History = require './history'

module.exports = Marionette.LayoutView.extend
  template: require './templates/admin_section'

  behaviors:
    PreventDefault: {}
    AlertBox: {}
    Loading: {}

  regions:
    history: '#history'

  ui:
    mergeWithInput: '#mergeWithField'
    historyTogglers: '#historyToggler i.fa'

  initialize: ->
    @_historyShown = false

  serializeData: ->
    mergeWith: mergeWithData()

  events:
    'click #mergeWithButton': 'merge'
    'click #historyToggler': 'toggleHistory'

  merge: (e)->
    behaviorsPlugin.startLoading.call @, '#mergeWithButton'

    fromUri = @model.get 'uri'
    toUri = @ui.mergeWithInput.val()
    # send to merge endpoint as everything should happen server side now
    _.preq.put app.API.entities.merge,
      from: fromUri
      to: toUri
    .then showRedirectedEntity.bind(null, fromUri, toUri)
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

showRedirectedEntity = (fromUri, toUri)->
  # Get the refreshed, redirected entity
  # thus also updating entitiesModelsIndexedByUri
  app.request 'get:entity:model', fromUri, true
  .then app.Execute('show:entity:from:model')
