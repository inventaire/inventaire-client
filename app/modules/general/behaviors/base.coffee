module.exports =
  initialize: ->
    Marionette.Behaviors.behaviorsLookup = ->
      app.Behaviors

  AlertBox: require './alertbox'
  ConfirmationModal: require './confirmation_modal'
  Loading: require './loading'
  SuccessCheck: require './success_check'
  TogglePassword: require './toggle_password'
  PreventDefault: require './prevent_default'
  ElasticTextarea: require './elastic_textarea'
  BackupForm: require './backup_form'
  LocalSeachBar: require './local_seach_bar'
  PlainTextAuthorLink: require './plain_text_author_link'
