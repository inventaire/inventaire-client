# add name => creates group
# invite friends
# invite by email

forms_ = require 'modules/general/lib/forms'
groups_ = require '../lib/groups'
groupPlugin = require '../plugins/group'
searchabilityData = require '../lib/searchability_data'

module.exports = Marionette.LayoutView.extend
  id: 'createGroupLayout'
  template: require './templates/create_group_layout'
  behaviors:
    AlertBox: {}

  regions:
    invite: '#invite'

  ui:
    nameField: '#nameField'
    step1: '#step1'
    searchabilityToggler: '#searchabilityToggler'
    step2: '#step2'
    allSteps: '.step'

  initialize: ->
    @initPlugin()

  initPlugin: ->
    groupPlugin.call @

  events:
    'click #createGroup': 'createGroup'

  createGroup: ->
    name = @ui.nameField.val()
    searchable = @ui.searchabilityToggler[0].checked
    if _.isNonEmptyString name
      _.preq.start()
      .then groups_.validateName.bind(@, name, '#nameField')
      .then groups_.createGroup.bind(null, name, searchable)
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
    searchability: searchabilityData()
