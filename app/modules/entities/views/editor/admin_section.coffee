forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'
behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/admin_section'

  behaviors:
    PreventDefault: {}
    AlertBox: {}
    Loading: {}

  ui:
    mergeWithInput: '#mergeWithField'

  serializeData: ->
    mergeWith: mergeWithData()

  events:
    'click #mergeWithButton': 'merge'

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
