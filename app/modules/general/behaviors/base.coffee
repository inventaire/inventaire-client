behaviors =
  General: require './general'
  AlertBox: require './alertbox'
  AutoComplete: require './autocomplete'
  AutoFocus: require './autofocus'
  Dropdown: require './dropdown'
  Loading: require './loading'
  SuccessCheck: require './success_check'
  TogglePassword: require './toggle_password'
  PreventDefault: require './prevent_default'
  ElasticTextarea: require './elastic_textarea'
  BackupForm: require './backup_form'
  Unselect: require './unselect'
  Toggler: require './toggler'
  DeepLinks: require './deep_links'
  Tooltip: require './tooltip'
  ClampedExtract: require './clamped_extract'
  EntitiesCommons: require './entities_commons'

module.exports =
  initialize: ->
    Marionette.Behaviors.behaviorsLookup = -> behaviors
