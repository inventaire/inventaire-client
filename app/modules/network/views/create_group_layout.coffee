# add name => creates group
# invite friends
# invite by email

forms_ = require 'modules/general/lib/forms'
groups_ = require '../lib/groups'
groupPlugin = require '../plugins/group'
groupFormData = require '../lib/group_form_data'

module.exports = Marionette.LayoutView.extend
  id: 'createGroupLayout'
  template: require './templates/create_group_layout'
  tagName: 'form'
  behaviors:
    AlertBox: {}
    ElasticTextarea: {}
    Toggler: {}

  regions:
    invite: '#invite'

  ui:
    nameField: '#nameField'
    description: '#description'
    searchabilityToggler: '#searchabilityToggler'
    searchabilityWarning: '.searchability .warning'

  initialize: ->
    @initPlugin()

  initPlugin: ->
    groupPlugin.call @

  events:
    'click #createGroup': 'createGroup'
    'change #searchabilityToggler': 'toggleSearchabilityWarning'
    'click #showPositionPicker': 'showPositionPicker'

  serializeData: ->
    description: groupFormData.description()
    searchability: groupFormData.searchability()

  toggleSearchabilityWarning: ->
    @ui.searchabilityWarning.slideToggle()

  showPositionPicker: ->
    app.request 'prompt:group:position:picker'
    .then (position)=> @position = position
    .catch _.Error('showPositionPicker')

  createGroup: (e)->
    name = @ui.nameField.val()
    description = @ui.description.val()

    data =
      name: name
      description: description
      searchable: @ui.searchabilityToggler[0].checked
      position: @position

    _.log data, 'group data'

    _.preq.start
    .then groups_.validateName.bind(@, name, '#nameField')
    .then groups_.validateDescription.bind(@, description, '#description')
    .then groups_.createGroup.bind(null, data)
    .then app.execute.bind(app, 'show:group:board')
    .catch forms_.catchAlert.bind(null, @)
