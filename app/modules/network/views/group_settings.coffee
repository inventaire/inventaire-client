{ icon } = require 'lib/handlebars_helpers/images'
behaviorsPlugin = require 'modules/general/plugins/behaviors'
forms_ = require 'modules/general/lib/forms'
groups_ = require '../lib/groups'
error_ = require 'lib/error'

module.exports = Marionette.ItemView.extend
  template: require './templates/group_settings'
  behaviors:
    AlertBox: {}
    PreventDefault: {}
    SuccessCheck: {}

  serializeData: ->
    attrs = @model.serializeData()
    _.extend attrs,
      editName: @editNameData(attrs.name)

  editNameData: (groupName)->
    nameBase: 'editName'
    field:
      value: groupName
      placeholder: _.logServer(groupName, 'groupName')
    button:
      # text: icon('check') + _.I18n 'save'
      text: _.I18n 'save'
    check: true

  ui:
    editNameField: '#editNameField'

  events:
    'click #editNameButton': 'editName'

  editName:->
    name = @ui.editNameField.val()
    if name?
      _.preq.start()
      .then groups_.validateName.bind(@, name, '#editNameField')
      .then _.Full(@_updateGroup, @, 'name', name, '#editNameField')
      .catch forms_.catchAlert.bind(null, @)

  _updateGroup: (attribute, value, selector)->
    app.request 'group:update:settings',
      model: @model
      attribute: attribute
      value: value
      selector: selector
