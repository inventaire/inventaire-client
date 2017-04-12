behaviors =
  General: require './general'
  AlertBox: require './alertbox'
  AutoComplete: require './autocomplete'
  AutoFocus: require './autofocus'
  Loading: require './loading'
  SuccessCheck: require './success_check'
  TogglePassword: require './toggle_password'
  PreventDefault: require './prevent_default'
  ElasticTextarea: require './elastic_textarea'
  BackupForm: require './backup_form'
  LocalSeachBar: require './local_seach_bar'
  PlainTextAuthorLink: require './plain_text_author_link'
  Unselect: require './unselect'
  Toggler: require './toggler'
  DeepLinks: require './deep_links'
  Tooltip: require './tooltip'

module.exports =
  initialize: ->
    Marionette.Behaviors.behaviorsLookup = -> behaviors
