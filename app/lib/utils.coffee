module.exports = (Backbone, _, app, window)->
  muted = require('./muted_logs')(_)
  utils =
    isMuted: (label)->
      if _.isString label
        tags = label.split ':'
        return tags.length > 1 and tags[0] in muted

    log: (obj, label, stack)->
      # customizing console.log
      # unfortunatly, it makes the console loose the trace
      # of the real line and file the _.log function was called from
      # the trade-off might not be worthing it...
      if _.isString obj
        if label? then obj.logIt(label)
        else console.log obj unless (@isMuted(obj) or @isMuted(label))
      else
        unless @isMuted(label)
          console.log "===== #{label} =====" if label? and not @isMuted(label)
          console.log obj
          console.log "-----" if label?

      # log a stack trace if stack option is true
      if stack
        console.log "#{label} stack", new Error('fake error').stack.split("\n")

      return obj

    error: (err, label)->
      unless err?.stack?
        label or= 'empty error'
        newErr = new Error(label)
        report = [err, newErr.message, newErr.stack?.split('\n')]
      else
        report = [err.message or err, err.stack?.split('\n')]
      window.reportErr {error: report}
      console.error.apply console, report

    logAllEvents: (obj, prefix='logAllEvents')->
      obj.on 'all', (event)->
        console.log "[#{prefix}:#{event}]"
        console.log arguments
        console.log '---'

    logArgs: (args)->
      console.log "[arguments]"
      console.log args
      console.log '---'

    logServer: (obj, label)->
      log = {obj: obj, label: label}
      $.post app.API.test, log

    logXhrErr: (err, label)->
      if err?.responseText? then label = "#{err.responseText} (#{label})"
      if err?.status?
        switch err.status
          when 401 then console.warn '401', label
          when 404 then console.warn '404', label
      else console.error label, err
      return

    setCookie: (key, value)->
      $.post '/api/cookie', {key: key, value: value}
      .then (res)-> _.log res, 'setCookie: server res on setCookie'
      .fail (err)-> console.error "setCookie: failed: #{key} - #{value}: #{err}"

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

    ping: ->
      @preq.get app.API.test
      .then ->
        app.online = true
        app.vent.trigger 'app:online'
      .catch (err)->
        app.online = false
        console.warn 'server: unreachable. You might be offline', err

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
      if Backbone.history.last?[0]?
        last = Backbone.history.last[0]
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

    isUserId: (id)-> /^\w{32}$/.test(id)

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

    # only addressing the general case
    env: (->
        if location.hostname is 'localhost' then return 'dev'
        else return 'prod'
      )()

    isUuid: (str)-> /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test str

    noop: ->

  String::logIt = (label)->
    console.log "[#{label}] #{@toString()}" unless utils.isMuted(label)
    return @toString()

  return utils