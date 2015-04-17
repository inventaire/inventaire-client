module.exports = Marionette.Behavior.extend
  ui:
    textarea: "textarea"

  onRender: ->
    @ui.textarea.elastic()
