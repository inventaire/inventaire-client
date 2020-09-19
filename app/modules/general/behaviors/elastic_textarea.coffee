autosize = require 'autosize'

module.exports = Marionette.Behavior.extend
  ui:
    textarea: 'textarea'

  events:
    'elastic:textarea:update': 'update'

  # Init somehow needs to be run on the next tick to be effective
  onRender: -> setTimeout @init.bind(@), 0

  init: ->
    # Known case: the view does not always display a textarea
    if @ui.textarea.length is 0 then return

    autosize @ui.textarea

  update: -> autosize.update @ui.textarea
