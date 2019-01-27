oneDay = 24 * 60 * 60 * 1000
error_ = requireProxy 'lib/error'

module.exports = (Backbone, _, $, app, window)->
  # Will be overriden in modules/user/lib/i18n.coffee as soon as possible
  i18n: _.identity
  I18n: (args...)-> _.capitalise _.i18n.apply(_, args)
  icon: (name, classes = '')-> "<i class='fa fa-#{name} #{classes}'></i>"

  inspect: (obj, label)->
    if _.isArguments obj then obj = _.toArray obj
    # remove after using as it keeps reference of the inspected object
    # making the garbage collection impossible
    if label?
      _.log obj, "#{label} added to window['#{label}'] for inspection"
      window[label] = obj
    else
      if window.current?
        window.previous or= []
        window.previous.unshift(window.current)
      window.current = obj

    return obj

  deepExtend: $.extend.bind($, yes)

  deepClone: (obj)->
    _.type obj, 'object'
    return JSON.parse JSON.stringify(obj)

  capitalise: (str)->
    if str is '' then return ''
    str[0].toUpperCase() + str[1..-1]

  isOpenedOutside: (e, ignoreMissingHref = false)->
    if e.currentTarget? then { id, href, className } = e.currentTarget

    unless e?.ctrlKey?
      error_.report 'non-event object was passed to isOpenedOutside', { id, href, className }
      # Better breaking an open outside behavior than not responding
      # to the event at all
      return false

    unless _.isNonEmptyString href
      unless ignoreMissingHref
        error_.report "can't open anchor outside: href is missing", { id, href, className }
      return false

    openInNewWindow = e.shiftKey
    # Anchor with a href are opened out of the current window when the ctrlKey is
    # pressed, or the metaKey (Command) in case its a Mac
    openInNewTabByKey = if isMac then e.metaKey else e.ctrlKey
    # Known case of missing currentTarget: leaflet formatted events
    openOutsideByTarget = e.currentTarget?.target is '_blank'
    return openInNewTabByKey or openInNewWindow or openOutsideByTarget

  cutBeforeWord: (text, limit)->
    shortenedText = text[0..limit]
    return shortenedText.replace /\s\w+$/, ''

  LazyRender: (view, timespan = 200, attachFocusHandler)->
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

  # Get the value from an object using a string
  # (equivalent to lodash deep 'get' function).
  # mimicking Lodash#get
  get: (obj, prop)-> prop.split('.').reduce objectWalker, obj

  sum: (array)-> array.reduce add, 0

  trim: (str)-> str.trim()

  focusInput: ($el)->
    $el.focus()
    value = $el[0]?.value
    unless value? then return
    $el[0].setSelectionRange 0, value.length

  # adapted from http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/
  hashCode: (string)->
    [ hash, i, len ] = [ 0, 0, string.length ]
    if len is 0 then return hash

    while i < len
      chr = string.charCodeAt(i)
      hash = ((hash << 5) - hash) + chr
      hash |= 0 # Convert to 32bit integer
      i++
    Math.abs hash

  haveAMatch: (arrayA, arrayB)->
    unless _.isArray(arrayA) and _.isArray(arrayB) then return false
    for valueA in arrayA
      for valueB in arrayB
        # Return true as soon as possible
        if valueA is valueB then return true
    return false

  objLength: (obj)-> Object.keys(obj)?.length

  expired: (timestamp, ttl)-> Date.now() - timestamp > ttl

  shortLang: (lang)-> lang?[0..1]

  # encodeURIComponent ignores !, ', (, ), and *
  # cf https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent#Description
  fixedEncodeURIComponent: (str)->
    encodeURIComponent(str).replace /[!'()*]/g, encodeCharacter

  pickOne: (obj)->
    key = Object.keys(obj)[0]
    if key? then return obj[key]

  isDataUrl: (str)-> /^data:image/.test str

  parseBooleanString: (booleanString, defaultVal = false)->
    if defaultVal is false
      booleanString is 'true'
    else
      booleanString isnt 'false'

  simpleDay: (date)->
    if date? then new Date(date).toISOString().split('T')[0]
    else new Date().toISOString().split('T')[0]

encodeCharacter = (c)-> '%' + c.charCodeAt(0).toString(16)

add = (a, b)-> a + b

objectWalker = (subObject, property)-> subObject?[property]

# Polyfill if needed
Date.now ?= -> new Date().getTime()

# source: http://stackoverflow.com/questions/10527983/best-way-to-detect-mac-os-x-or-windows-computers-with-javascript-or-jquery
isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0
