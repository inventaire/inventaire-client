module.exports = Marionette.Behavior.extend
  events:
    'loading': 'showSpinningLoader'
    'stopLoading': 'hideSpinningLoader'
    'somethingWentWrong': 'somethingWentWrong'

  showSpinningLoader: (e, params = {})->
    { selector, message, timeout } = params
    @$target = @getTarget selector
    # _.log @$target, '@$target'

    body = _.icon 'circle-o-notch', 'fa-spin'
    if message?
      mes = params.message
      body += "<p class='grey'>#{mes}</p>"

    @$target.html body

    timeout or= 30
    unless timeout is 'none'
      cb = @somethingWentWrong.bind @, null, params
      setTimeout cb, timeout * 1000

  hideSpinningLoader: (e, params = {})->
    @$target or= @getTarget params.selector
    @$target.empty()
    @hidden = true

  somethingWentWrong: (e, params = {})->
    unless @hidden
      @$target or= @getTarget params.selector

      oups = _.I18n 'something went wrong :('
      body = _.icon('bolt') + "<p> #{oups}</p>"

      @$target.html body

  # Priority:
  # - #{selector} .loading
  # - #{selector}
  # - .loading
  getTarget: (selector)->
    if _.isNonEmptyString selector
      $target = @$el.find selector
      $targetAlt = $target.find '.loading'
      if $targetAlt.length is 1 then $targetAlt else $target
    else
      @$el.find '.loading'
