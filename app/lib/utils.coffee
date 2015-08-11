regex_ = sharedLib 'regex'

module.exports = (Backbone, _, app, window, console)->

  loggers = require('./loggers')(_, console)

  utils =
    setCookie: (key, value)->
      @preq.post '/api/cookie', {key: key, value: value}
      .then _.Log('setCookie: server res on setCookie')
      .catch _.Error("setCookie: failed: #{key} - #{value}")

    i18n: (key, args)-> app.polyglot.t key, args
    I18n: (args...)-> _.capitaliseFirstLetter _.i18n.apply(_, args)

    updateQuery: (newParams)->
      [pathname, currentQueryString] = Backbone.history.fragment.split('?')
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
      return window.current = obj

    hasKnownUriDomain: (str)->
      if _.isString(str)
        [prefix, id] = str.split(':')
        if prefix? and id?
          switch prefix
            when 'wd'
              if app.lib.wikidata.isWikidataId id then return true
            when 'isbn'
              if app.lib.books.isIsbn id then return true
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

    isFirefox: -> window.navigator?.mozApps?

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
      array.forEach (el)-> if not test(el) then result = false
      return result

    isUri: (str)->
      [prefix, id] = str.split ':'
      if prefix? and id?
        switch prefix
          when 'wd' then return wd.isWikidataId(id)
          when 'isbn' then return app.lib.books.isNormalizedIsbn(id)
      return false

    uniq: (array)->
      obj = {}
      array.forEach (value)-> obj[value] = true
      return Object.keys(obj)

    # adapted from lodash implementation
    values: (obj) ->
      index = -1
      props = Object.keys(obj)
      length = props.length
      result = Array(length)
      result[index] = obj[props[index]]  while ++index < length
      return result

    localUrl: (url)-> /^\//.test(url)

    allValues: (obj)-> @flatten @values(obj)

    now: -> new Date().getTime()

    objectifyPairs: (array)->
      pairs = array.length / 2
      if pairs % 1 isnt 0
        err = 'expected pairs, got odd number of arguments'
        throw new Error(err, arguments)

      obj = {}
      if pairs >= 1
        i = 0
        while i < pairs
          [key, value] = [ array[i], array[i+1] ]
          obj[key] = value
          i += 1

      return obj

    smallScreen: (ceil=1024)-> window.screen.width < ceil

    deepClone: (obj)->
      @type obj, 'object'
      return JSON.parse JSON.stringify(obj)

    capitaliseFirstLetter: (str)-> str[0].toUpperCase() + str[1..-1]

    isUuid: (str)-> regex_.Uuid.test str
    isEmail: (str)-> regex_.Email.test str
    isUserId: (id)-> regex_.CouchUuid.test(id)

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

    # scroll to the top of an $el
    scrollTop: ($el, duration=500)->
      # Polymorphism: accept jquery objects or selector strings as $el
      if _.isString then $el = $($el)
      top = $el.position().top
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

  return _.extend {}, utils, loggers
