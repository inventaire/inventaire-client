module.exports = class ConfirmationModal extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require './templates/confirmation_modal'
  onShow: -> app.execute 'modal:open'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  serializeData: ->
    confirmationText: @options.confirmationText
    warningText: @options.warningText

  events:
    'click a#yes': 'yesClick'
    'click a#no': 'close'

  yesClick: ->
    app.request 'waitForCheck',
      action: => @options.actionCallback(@options.actionArgs)
      $selector: @$el
      success: @close
      error: @close

  close: -> app.execute('modal:close')