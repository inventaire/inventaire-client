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
  behaviors:
    AlertBox: {}
    ElasticTextarea: {}

  regions:
    invite: '#invite'

  ui:
    nameField: '#nameField'
    description: '#description'
    step1: '#step1'
    searchabilityToggler: '#searchabilityToggler'
    searchabilityWarning: '.searchability .warning'
    step2: '#step2'
    allSteps: '.step'

  initialize: ->
    @initPlugin()

  initPlugin: ->
    groupPlugin.call @

  events:
    'click #createGroup': 'createGroup'
    'change #searchabilityToggler': 'toggleSearchabilityWarning'

  createGroup: ->
    name = @ui.nameField.val()
    description = @ui.description.val()
    searchable = @ui.searchabilityToggler[0].checked

    _.preq.start()
    .then groups_.validateName.bind(@, name, '#nameField')
    .then groups_.validateDescription.bind(@, description, '#description')
    .then groups_.createGroup.bind(null, name, description, searchable)
    .then @setModel.bind(@)
    .then @showStepTwo.bind(@)
    .catch forms_.catchAlert.bind(null, @)

  setModel: (group)->
    @model = group

  showStepTwo: ->
    @showFriendsInvitor()
    @ui.allSteps.fadeOut()
    @ui.step2.fadeIn()

  showFriendsInvitor: ->
    @invite.show @getFriendsInvitorView()

  serializeData: ->
    description: groupFormData.description()
    searchability: groupFormData.searchability()

  toggleSearchabilityWarning: ->
    @ui.searchabilityWarning.slideToggle()
