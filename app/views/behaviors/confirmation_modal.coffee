module.exports = class ConfirmationModal extends Backbone.Marionette.ItemView
  tagName: 'div'
  template: require 'views/behaviors/templates/confirmation_modal'
  onShow: -> app.execute 'modal:open'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
  serializeData: ->
    attrs =
      confirmationText: @options.params.confirmationText
      warningText: @options.params.warningText
    return attrs

  events:
    'click #yes': ->
      @options.params.actionCallback @options.params.actionArgs
      .then (res)=> @$el.trigger 'check', -> app.execute 'modal:close'
      .fail (err)=> @$el.trigger 'fail', -> app.execute 'modal:close'
    'click #no': -> app.execute 'modal:close'