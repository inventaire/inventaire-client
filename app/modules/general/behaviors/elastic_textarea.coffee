module.exports = Marionette.Behavior.extend
  ui:
    textarea: "textarea"

  onRender: ->
    autosize(@ui.textarea)
