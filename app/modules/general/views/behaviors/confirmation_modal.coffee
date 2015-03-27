module.exports = ConfirmationModal = Backbone.Marionette.ItemView.extend
  tagName: 'div'
  template: require './templates/confirmation_modal'
  onShow: -> app.execute 'modal:open'
  behaviors:
    SuccessCheck: {}

  serializeData: ->
    confirmationText: @options.confirmationText
    warningText: @options.warningText

  events:
    'click a#yes': 'yesClick'
    'click a#no': 'close'

  yesClick: ->
    {action, selector} = @options
    _.preq.start()
    .then action
    .then @success.bind(@)
    .catch @error.bind(@)
    .finally @stopLoading.bind(null, selector)

  success: (res)->
    _.log res, 'confirmation action res'
    @$el.trigger 'check', @close.bind(@)
    return res

  error: (check, err)->
    _.error err, 'confirmation action err'
    @$el.trigger 'fail', @close.bind(@)
    return err

  close: ->
    app.execute('modal:close')

  stopLoading: (selector)->
    if selector? then $(selector).trigger('stopLoading')
    else _.warn 'no selector was provided'