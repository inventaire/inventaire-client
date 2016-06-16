wd_ = requireProxy 'lib/wikidata'
books_ = requireProxy 'lib/books'
regex_ = sharedLib 'regex'
tests_ = sharedLib('tests')(regex_)
isCouchUuid = regex_.CouchUuid.test.bind(regex_.CouchUuid)
oneDay = 24*60*60*1000

module.exports = (Backbone, _, $, app, window, csle)->
  loggers = require('./loggers')(_, csle)

  utils =
    setCookie: (key, value)->
      @preq.post '/api/cookie', {key: key, value: value}
      .catch _.Error("setCookie: failed: #{key} - #{value}")

    i18n: require './translate'
    I18n: (args...)-> _.capitaliseFirstLetter _.i18n.apply(_, args)
    icon: (name, classes)->
      "<i class='fa fa-#{name} #{classes}'></i>&nbsp;&nbsp;"

    updateQuery: (newParams)->
      [ pathname, currentQueryString ] = Backbone.history.fragment.split('?')
      query = @parseQuery(currentQueryString)
      _.extend query, newParams
      route = @buildPath(pathname, query)
      if route? then app.navigate(route)
      else _.error [query, newParams], 'couldnt updateQuery'

    inspect: (obj, label)->
      # remove after using as it keeps reference of the inspected object
      # making the garbage collection impossible
      if label? then _.log obj, "#{label} added to window.current for inspection"
      if window.current?
        window.previous or= []
        window.previous.unshift(window.current)

      if _.isArguments obj then obj = _.toArray obj
      return window.current = obj

    hasKnownUriDomain: (str)->
      if _.isString(str)
        [ prefix, id ] = str.split(':')
        if prefix? and id?
          switch prefix
            when 'wd'
              if wd_.isWikidataId id then return true
            when  isbn
              if books_.isIsbn id then return true
            when 'inv'
              if @isUuid(id) then return true
      return false

    lastRouteMatch: (regex)->
      if Backbone.history.last?[1]?
        last = Backbone.history.last[1]
        return regex.test(last)
      else false

    openJsonWindow: (obj, windowName)->
      json = JSON.stringify obj, null, 4
      data = 'data:application/json;charset=utf-8,' + encodeURI(json)
      window.open data, windowName

    style: (text, style)->
      switch style
        when 'strong' then "<strong>#{text}</strong>"

    stringOnly: (str)->
      if typeof str is 'string' then str
      else return

    isntEmpty: (array)-> not @isEmpty(array)
    pickOne: (obj)->
      k = Object.keys(obj)[0]
      return obj[k]

    isModel: (obj)-> obj instanceof Backbone.Model
    isView: (obj)-> obj instanceof Backbone.View

    validImageSrc: (url, callback)->
      image = new Image()
      image.src = url
      cb = ->
        if image.complete then @preq.resolve(url)
        else @preq.reject(url)
      setTimeout cb, 500

    allValid: (array, test)->
      result = true
      for el in array
        if not test(el) then result = false
      return result

    isUri: (str)->
      [ prefix, id ] = str.split ':'
      if prefix? and id?
        switch prefix
          when 'wd' then return wd.isWikidataId id
          when 'isbn' then return books_.isNormalizedIsbn id
      return false

    uniq: (array)->
      obj = {}
      for value in array
        obj[value] = true
      return Object.keys(obj)

    # adapted from lodash implementation
    values: (obj)->
      index = -1
      props = Object.keys(obj)
      length = props.length
      result = Array(length)
      result[index] = obj[props[index]]  while ++index < length
      return result

    localUrl: (url)-> /^\//.test(url)

    allValues: (obj)-> @flatten @values(obj)

    now: -> new Date().getTime()

    getYearFromEpoch: (epochTime)-> new Date(epochTime).getYear() + 1900
    yearsAgo: (years)-> new Date().getYear() + 1900 - years

    objectifyPairs: (array)->
      pairs = array.length / 2
      if pairs % 1 isnt 0
        err = 'expected pairs, got odd number of arguments'
        throw new Error(err, arguments)

      obj = {}
      if pairs >= 1
        i = 0
        while i < pairs
          [ key, value ] = [ array[i], array[i+1] ]
          obj[key] = value
          i += 1

      return obj

    # /!\ window.screen.width is the screen's width not the current window width
    screenWidth: -> $(window).width()
    screenHeight: -> $(window).height()
    # keep in sync with app/modules/general/scss/_grid_and_media_query_ranges.scss
    smallScreen: (ceil=1000)-> utils.screenWidth() < ceil

    deepClone: (obj)->
      @type obj, 'object'
      return JSON.parse JSON.stringify(obj)

    capitaliseFirstLetter: (str)->
      if str is '' then return ''
      str[0].toUpperCase() + str[1..-1]

    isUuid: (str)-> regex_.Uuid.test str
    isEmail: (str)-> regex_.Email.test str
    isUserId: isCouchUuid
    isItemId: isCouchUuid
    isUsername: (username)-> regex_.Username.test username
    isEntityUri: (uri)-> regex_.EntityUri.test uri

    # anchor with a href are opened out of the current window
    # when the ctrlKey is pressed: the normal action should thus be prevented
    isOpenedOutside: (e)-> e.ctrlKey

    noop: ->

    escapeKeyPressed: (e)-> e.keyCode is 27

    currentRoute: -> location.pathname.slice(1)
    currentQuerystring: -> location.search
    setQuerystring: (url, key, value)->
      [ href, qs ] = url.split('?')
      if qs?
        qsObj = _.parseQuery qs
        # override the previous key/value
        qsObj[key] = value
        return _.buildPath href, qsObj
      else
        return "#{href}?#{key}=#{value}"

    # calling a section the first part of the route matching to a module
    # ex: for '/inventory/bla/bla', the section is 'inventory'
    routeSection: (route)->
      # split on the first non-alphabetical character
      route.split(/[^\w]/)[0]

    currentSection: ->
      _.routeSection _.currentRoute()

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

    stringContains: (str, target)->
      str.split(target).length > 1

    cutBeforeWord: (text, limit)->
      shortenedText = text[0..limit]
      return shortenedText.replace /\s\w+$/, ''

    isCanvas: (obj)-> obj?.nodeName?.toLowerCase() is 'canvas'

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

    daysAgo: (epochTime)-> Math.floor(( _.now() - epochTime ) / oneDay)

    deepExtend: $.extend.bind($, yes)

    # Get the value from an object using a string
    # (equivalent to lodash deep 'get' function).
    get: (obj, prop)-> prop.split('.').reduce objectWalker, obj

    # Returns a .catch function that execute the reverse action
    # then passes the error to the next .catch
    Rollback: (reverseAction, label)->
      return rollback = (err)->
        if label? then _.log "rollback: #{label}"
        reverseAction()
        throw err

  return _.extend {}, utils, loggers, tests_

objectWalker = (subObject, property)-> subObject?[property]
