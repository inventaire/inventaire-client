autosize = require 'autosize'

module.exports = Marionette.Behavior.extend
  ui:
    textarea: 'textarea'

  events:
    'elastic:textarea:update': 'update'

  onRender: ->
    autosize @ui.textarea

  update: ->
    autosize.update @ui.textarea
