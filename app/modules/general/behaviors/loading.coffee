module.exports = Marionette.Behavior.extend
  events:
    'loading': 'showSpinningLoader'
    'stopLoading': 'hideSpinningLoader'
    'somethingWentWrong': 'somethingWentWrong'

  showSpinningLoader: (e, params)->
    @$target = @getTarget params
    # _.log @$target, '@$target'

    body = _.icon 'circle-o-notch', 'fa-spin'
    if params?.message?
      mes = params.message
      body += "<p class='grey'>#{mes}</p>"

    @$target.html body

    timeout = params?.timeout or 30
    unless timeout is 'none'
      cb = @somethingWentWrong.bind @, null, params
      setTimeout cb, timeout * 1000

  hideSpinningLoader: (e, params)->
    @$target or= @getTarget params
    @$target.empty()
    @hidden = true

  somethingWentWrong: (e, params)->
    unless @hidden
      @$target or= @getTarget params

      oups = _.I18n 'something went wrong :('
      body = _.icon('bolt') + "<p> #{oups}</p>"

      @$target.html body

  getTarget: (params)->
    # _.log params, 'params'
    if params?.selector? then @$el.find(params.selector).find '.loading'
    else @$el.find '.loading'
