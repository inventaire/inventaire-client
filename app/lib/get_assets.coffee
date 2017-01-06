# An API to get scripts that weren't bundled into vendor.js
# Names are expected to match app/api/scripts.coffee keys

module.exports = (name, onScriptReady)->
  promise = null
  alreadyPrepared = false
  onScriptReady or= _.identity

  get = ->
    unless promise?
      _.log name, 'fetching script'
      alreadyPrepared = true

      # Get the javascript file associated to this name
      scriptPromise = _.preq.getScript app.API.assets.scripts[name]()
        .then onScriptReady
        .catch _.ErrorRethrow("get script #{name}")

      _promises = [ scriptPromise ]

      # Get the stylesheet associated if any
      stylesheetUrlGetter = app.API.assets.stylesheets[name]
      if stylesheetUrlGetter?
        _promises.push _.preq.getCss(stylesheetUrlGetter())

      promise = Promise.all _promises

    return promise

  return API =
    # Pre-fetch the script when the script is probably about to be used
    # to be ready to start using it faster
    prepare: ->
      unless alreadyPrepared then get()
      # We don't need to return a promise here
      # If we need a promise it's that be directly depend on the script arrival
      # thus 'get' should be used instead
      return null
    get: get
