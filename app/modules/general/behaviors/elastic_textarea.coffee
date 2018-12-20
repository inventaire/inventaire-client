module.exports = Marionette.Behavior.extend
  ui:
    textarea: 'textarea'

  events:
    'elastic:textarea:update': 'update'

  onRender: ->
    window.autosize @ui.textarea

  update: ->
    window.autosize.update @ui.textarea
