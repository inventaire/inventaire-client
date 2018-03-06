module.exports = Marionette.ItemView.extend
  template: require './templates/candidate_info'
  className: 'candidate-info'

  initialize: ->
    # Terminate the promise
    @listenTo app.vent, 'modal:closed', @onClose.bind(@)

  onShow: -> app.execute 'modal:open'

  ui:
    title: 'input[name="title"]'
    authors: 'input[name="authors"]'
    validateInfo: '.validateInfo'
    disabledValidateInfo: '.disabledValidateInfo'

  events:
    'keyup input[name="title"]': 'updateButton'
    'click .validateInfo': 'validateInfo'

  updateButton: (e)->
    if e.currentTarget.value is ''
      @ui.validateInfo.addClass 'hidden'
      @ui.disabledValidateInfo.removeClass 'hidden'
    else
      @ui.disabledValidateInfo.addClass 'hidden'
      @ui.validateInfo.removeClass 'hidden'

  validateInfo: ->
    title = @ui.title.val()
    authors = @ui.authors.val()
    @options.resolve { title, authors }
    @_resolved = true
    app.execute 'modal:close'

  onClose: ->
    unless @_resolved then @options.reject new Error('modal closed')
