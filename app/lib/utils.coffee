oneDay = 24*60*60*1000

module.exports = (Backbone, _, $, app, window)->
  # sync
  getCookie: (key)->
    value = $.cookie key
    return parseCookieValue value

  # async
  setCookie: (key, value)->
    _.preq.post app.API.cookie, {key: key, value: value}
    .catch _.Error("setCookie: failed: #{key} - #{value}")

  i18n: require './translate'
  I18n: (args...)-> _.capitaliseFirstLetter _.i18n.apply(_, args)
  icon: (name, classes='')-> "<i class='fa fa-#{name} #{classes}'></i>&nbsp;&nbsp;"

  parseQuery: (queryString)->
    query = {}
    if queryString?
      queryString
      .replace /^\?/, ''
      .split '&'
      .forEach ParseKeysValues(query)
    return query

  # Should not be useful anymore as urls with labels were removed
  # Possible exception: short group names apparently still need it
  softDecodeURI: (str)->
    _.typeString str
    .replace /_/g,' '

  # Not used: waiting for _.softDecodeURI to be ready for removal to remove
  # softEncodeURI: (str)->
  #   _.typeString str
  #   .replace /(\s|')/g, '_'
  #   .replace /\?/g, ''

  piped: (data)-> _.forceArray(data).join '|'

  inspect: (obj, label)->
    # remove after using as it keeps reference of the inspected object
    # making the garbage collection impossible
    if label? then _.log obj, "#{label} added to window.current for inspection"
    if window.current?
      window.previous or= []
      window.previous.unshift(window.current)

    if _.isArguments obj then obj = _.toArray obj
    return window.current = obj

  lastRouteMatch: (regex)->
    if Backbone.history.last?[1]?
      last = Backbone.history.last[1]
      return regex.test(last)
    else false

  isntEmpty: (array)-> not _.isEmpty(array)

  pickToArray: (obj, props...)->
    if _.isArray(props[0]) then props = props[0]
    _.typeArray props
    pickObj = _.pick(obj, props)
    # returns an undefined array element when prop is undefined
    return props.map (prop)-> pickObj[prop]

  # /!\ window.screen.width is the screen's width not the current window width
  screenWidth: -> $(window).width()
  screenHeight: -> $(window).height()
  # keep in sync with app/modules/general/scss/_grid_and_media_query_ranges.scss
  smallScreen: (ceil=1000)-> _.screenWidth() < ceil

  deepExtend: $.extend.bind($, yes)
  deepClone: (obj)->
    _.type obj, 'object'
    return JSON.parse JSON.stringify(obj)

  capitaliseFirstLetter: (str)->
    if str is '' then return ''
    str[0].toUpperCase() + str[1..-1]

  isOpenedOutside: (e)->
    unless e?.ctrlKey?
      reportImplementationError 'non-event object was passed to isOpenedOutside'
      # Better breaking an open outside behavior than not responding
      # to the event at all
      return false

    unless _.isNonEmptyString e.currentTarget?.href
      reportImplementationError "can't open anchor outside: href is missing"
      return false

    # Anchor with a href are opened out of the current window when the ctrlKey is
    # pressed, or the metaKey (Command) in case its a Mac
    openOutsideByKey = if isMac then e.metaKey else e.ctrlKey
    # Known case of missing currentTarget: leaflet formatted events
    openOutsideByTarget = e.currentTarget?.target is '_blank'
    return openOutsideByKey or openOutsideByTarget

  noop: ->

  currentRoute: -> location.pathname.slice(1)
  setQuerystring: (url, key, value)->
    [ href, qs ] = url.split '?'
    qsObj = _.parseQuery qs
    # override the previous key/value
    qsObj[key] = value
    return _.buildPath href, qsObj

  # calling a section the first part of the route matching to a module
  # ex: for '/inventory/bla/bla', the section is 'inventory'
  routeSection: (route)->
    # split on the first non-alphabetical character
    route.split(/[^\w]/)[0]

  currentSection: -> _.routeSection _.currentRoute()

  # Scroll to the top of an $el
  # Increase marginTop to scroll to a point before the element top
  scrollTop: ($el, duration=500, marginTop=0)->
    # Polymorphism: accept jquery objects or selector strings as $el
    if _.isString then $el = $($el)
    top = $el.position().top - marginTop
    $('html, body').animate {scrollTop: top}, duration

  # scroll to a given height
  scrollHeight: (height, ms=500)->
    $('html, body').animate {scrollTop: height}, ms

  # let the view call the plugin with the view as context
  # ex: module.exports = _.BasicPlugin events, handlers
  BasicPlugin: (events, handlers)->
    _.partial _.basicPlugin, events, handlers

  # expected to be passed a view as context, an events object
  # and the associated handlers
  # ex: _.basicPlugin.call @, events, handlers
  basicPlugin: (events, handlers)->
    @events or= {}
    _.extend @events, events
    _.extend @, handlers
    return

  cutBeforeWord: (text, limit)->
    shortenedText = text[0..limit]
    return shortenedText.replace /\s\w+$/, ''

  LazyRender: (view, timespan=200, attachFocusHandler)->
    cautiousRender = (focusSelector)->
      unless view.isDestroyed
        view.render()
        if _.isString focusSelector then view.$el.find(focusSelector).focus()

    if attachFocusHandler
      view.LazyRenderFocus = (focusSelector)->
        return fn = -> view.lazyRender focusSelector

    return _.debounce cautiousRender, timespan

  invertAttr: ($target, a, b)->
    aVal = $target.attr a
    bVal = $target.attr b
    $target.attr a, bVal
    $target.attr b, aVal

  daysAgo: (epochTime)-> Math.floor(( Date.now() - epochTime ) / oneDay)

  timeSinceMidnight: ->
    today = _.simpleDay()
    midnight = new Date(today).getTime()
    return Date.now() - midnight

  # Returns a .catch function that execute the reverse action
  # then passes the error to the next .catch
  Rollback: (reverseAction, label)->
    return rollback = (err)->
      if label? then _.log "rollback: #{label}"
      reverseAction()
      throw err


  # Tests (compeling app/lib/shared/tests for the client needs)
  isModel: (obj)-> obj instanceof Backbone.Model
  isView: (obj)-> obj instanceof Backbone.View
  isCanvas: (obj)-> obj?.nodeName?.toLowerCase() is 'canvas'

  allValues: (obj)-> _.flatten _.values(obj)

  # Functions mimicking Lodash

  # Get the value from an object using a string
  # (equivalent to lodash deep 'get' function).
  get: (obj, prop)-> prop.split('.').reduce objectWalker, obj

  # adapted from lodash implementation
  values: (obj)->
    index = -1
    props = Object.keys obj
    length = props.length
    result = Array length

    while ++index < length
      result[index] = obj[props[index]]

    return result

  sum: (array)-> array.reduce add, 0

  isIntegerString: (str)-> /^\d+$/.test str

add = (a, b)-> a + b

objectWalker = (subObject, property)-> subObject?[property]

parseCookieValue = (value)->
  switch value
    when 'true' then true
    when 'false' then false
    else value

# Polyfill if needed
Date.now or= -> new Date().getTime()

# source: http://stackoverflow.com/questions/10527983/best-way-to-detect-mac-os-x-or-windows-computers-with-javascript-or-jquery
isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0

ParseKeysValues = (queryObj)-> (param)->
  pairs = param.split '='
  [ key, value ] = pairs
  if key?.length > 0 and value?
    # Try to parse the value, allowing JSON strings values
    # like data={%22wdt:P50%22:[%22wd:Q535%22]}
    value = permissiveJsonParse decodeURIComponent(value)
    # If a number string was parsed into a number, make it a string again
    # so that the output stays predictible
    if _.isNumber value then value = value.toString()
    # If it's still a string and not an object, soft decode it
    if _.isString value then value = _.softDecodeURI value
    queryObj[key] = value

permissiveJsonParse = (input)->
  try JSON.parse input
  catch err then input

reportImplementationError = (message)->
  err = new Error message
  err.statusCode = 500
  _.error err, message
  return
