module.exports = class ConfirmationModal extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/behaviors/templates/confirmation_modal'
  onShow: -> app.execute 'modal:open'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  serializeData: ->
    confirmationText: @options.confirmationText
    warningText: @options.warningText

  events:
    'click #yes': 'yesClick'
    'click #no': -> app.execute 'modal:close'

  yesClick: ->
    close = -> app.execute('modal:close')
    app.execute 'waitForCheck',
      action: => @options.actionCallback(@options.actionArgs)
      $selector: @$el
      success: close
      error: close