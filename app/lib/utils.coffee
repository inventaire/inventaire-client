regex_ = sharedLib 'regex'

module.exports = (Backbone, _, app, window)->

  loggers = require('./loggers')(_)

  utils =
    setCookie: (key, value)->
      @preq.post '/api/cookie', {key: key, value: value}
      .then (res)-> _.log res, 'setCookie: server res on setCookie'
      .catch (err)-> console.error "setCookie: failed: #{key} - #{value}: #{err}"

    i18n: (key, args)-> app.polyglot.t key, args

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

    dropProtocol: (path)-> path.replace /^(https?:)?\/\//, ''

    cdn: (path, width, height, extend)->
      # cdn.filter.to doesnt support https
      unless /^https/.test path
        unless _.isNumber(height) then height = width
        size = "#{width}x#{height}"
        unless extend then size += 'g'
        path = @dropProtocol path
        return "http://cdn.filter.to/#{size}/#{path}"
      else return path

    placeholder: (height=250, width=200)->
      text = _.i18n 'missing image'
      return "http://placehold.it/#{width}x#{height}/ddd/fff&text=#{text}"

    openJsonWindow: (obj, windowName)->
      json = JSON.stringify obj, null, 4
      data = 'data:application/json;charset=utf-8,' + encodeURI(json)
      window.open data, windowName


    isMainUser: (id)->
      if id? then return id is app.user.id

    isFriend: (id)->
      unless id? and app.user.relations? then return false
      return id in app.user.relations.friends

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

    currentLocationMatch: (str)->
      pattern = new RegExp(str)
      return pattern.test window.location.pathname

    isModel: (obj)-> obj instanceof Backbone.Model

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
    expired: (timestamp, ttl)-> @now() - timestamp > ttl

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
          console.log key, value
          obj[key] = value
          i += 1

      return obj

    smallScreen: -> window.screen.width < 1024

    deepClone: (obj)->
      @type obj, 'object'
      return JSON.parse JSON.stringify(obj)

    capitaliseFirstLetter: (str)-> str[0].toUpperCase() + str[1..-1]

    isUuid: (str)-> regex_.Uuid.test str
    isEmail: (str)-> regex_.Email.test str
    isUserId: (id)-> regex_.CouchUuid.test(id)

    noop: ->

  return _.extend {}, utils, loggers
