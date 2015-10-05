module.exports = Marionette.ItemView.extend
  className: 'confirmationModal'
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
    @$el.trigger 'check', @close.bind(@)
    return res

  error: (err)->
    _.error err, 'confirmation action err'
    @$el.trigger 'fail', @close.bind(@)
    return err

  close: ->
    app.execute('modal:close')

  stopLoading: (selector)->
    if selector? then $(selector).trigger('stopLoading')
    else _.warn 'no selector was provided'
