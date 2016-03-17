module.exports = Marionette.ItemView.extend
  className: 'confirmationModal'
  template: require './templates/confirmation_modal'
  behaviors:
    SuccessCheck: {}
    ElasticTextarea: {}
    General: {}

  ui:
    no: '#no'

  serializeData: ->
    data = @options
    data.yes or= 'yes'
    data.no or= 'no'
    return data

  events:
    'click a#yes': 'yesClick'
    'click a#no': 'close'

  onShow: ->
    app.execute 'modal:open'
    # trigger once the modal is done sliding down
    setTimeout @ui.no.focus.bind(@ui.no), 600

  yesClick: ->
    { action, selector } = @options
    _.preq.start
    .then @executeFormAction.bind(@)
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

  executeFormAction: ->
    { formAction } = @options
    if formAction?
      formContent = @$el.find('#confirmationForm').val()
      if _.isNonEmptyString formContent
        return formAction formContent
