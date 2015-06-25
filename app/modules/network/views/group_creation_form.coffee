# add name => creates group
# invite friends
# invite by email

forms_ = require 'modules/general/lib/forms'
groups_ = require '../lib/groups'

module.exports = Marionette.LayoutView.extend
  template: require './templates/group_creation_form'
  behaviors:
    AlertBox: {}

  ui:
    nameField: '#nameField'
    step1: '#step1'
    step2: '#step2'
    step3: '#step3'
    allSteps: '.step'

  events:
    'click #createGroup': 'createGroup'

  createGroup: ->
    name = @ui.nameField.val()
    if name?
      _.preq.start()
      .then groups_.validateName.bind(@, name, '#nameField')
      .then groups_.createGroup.bind(null, name)
      .then @showStepTwo.bind(@)
      .catch forms_.catchAlert.bind(null, @)

  showStepTwo: ->
    @ui.allSteps.fadeOut()
    @ui.step2.fadeIn()

