module.exports =
  initialize: ->
    Marionette.Behaviors.behaviorsLookup = ->
      app.Behaviors

  AlertBox: require './alertbox'
  ConfirmationModal: require './confirmation_modal'
  Loading: require './loading'
  SuccessCheck: require './success_check'
  WikiBar: require './wiki_bar'
  TogglePassword: require './toggle_password'
  PreventDefault: require './prevent_default'
  ElasticTextarea: require './elastic_textarea'
