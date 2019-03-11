module.exports = Marionette.Behavior.extend
  events:
    'loading': 'showSpinningLoader'
    'stopLoading': 'hideSpinningLoader'
    'somethingWentWrong': 'somethingWentWrong'

  showSpinningLoader: (e, params = {})->
    { selector, message, timeout, progressionEventName } = params
    @$target = @getTarget selector
    # _.log @$target, '@$target'

    body = '<div class="small-loader"></div>'
    if message?
      mes = params.message
      body += "<p class='grey'>#{mes}</p>"

    $parent = @$target.parent()

    # If the container is flex, no need to adjust to get the loader centered
    if $parent.css('display') isnt 'flex'
      body = body.replace 'small-loader', 'small-loader adjust-vertical-alignment'

    @$target.html body
    # Elements to hide when loading should share the same parent as the .loading element
    $parent.find('.hide-on-loading').hide()

    timeout or= 30
    unless timeout is 'none'
      cb = @somethingWentWrong.bind @, null, params
      @view.setTimeout cb, timeout * 1000

    if progressionEventName?
      if @_alreadyListingForProgressionEvent then return
      @_alreadyListingForProgressionEvent = true

      fn = updateProgression.bind @, body
      lazyUpdateProgression = _.debounce fn, 500, true
      @listenTo app.vent, progressionEventName, lazyUpdateProgression

  hideSpinningLoader: (e, params = {})->
    @$target or= @getTarget params.selector
    @$target.empty()
    @$target.parent().find('.hide-on-loading').show()
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

updateProgression = (body, data)->
  if @hidden then return
  counter = "#{data.done}/#{data.total}"
  @$target.html "<span class='progression'>#{counter}</span> #{body}"
