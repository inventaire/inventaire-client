autosize = require 'autosize'

module.exports = Marionette.Behavior.extend
  ui:
    textarea: 'textarea'

  events:
    'elastic:textarea:update': 'update'

  # Init somehow needs to be run on the next tick to be effective
  onRender: -> setTimeout @init.bind(@), 0

  init: ->
    if @ui.textarea.length is 0 then console.error 'textarea not found'
    else autosize @ui.textarea

  update: -> autosize.update @ui.textarea
