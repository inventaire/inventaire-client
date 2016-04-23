# An API to get scripts that weren't bundled into vendor.js
# Names are expected to match app/api/scripts.coffee keys

module.exports = (name)->
  promise = null
  alreadyPrepared = false

  get = ->
    unless promise?
      _.log name, 'fetching script'
      alreadyPrepared = true
      promise = _.preq.getScript app.API.scripts[name]()

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
