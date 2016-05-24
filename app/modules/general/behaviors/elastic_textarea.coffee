module.exports = Marionette.Behavior.extend
  ui:
    textarea: "textarea"

  onRender: ->
    window.autosize @ui.textarea
