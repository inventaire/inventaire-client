module.exports = ->
  # if localStorage isnt supported (or more probably, blocked), replace it by a global object:
  # data won't be persisted from one session to the other, but who's fault is that
  try
    window.localStorage.setItem 'localStorage-support', true
    localStorageProxy = localStorage
  catch err
    console.warn 'localStorage isnt supported'
    storage = {}
    localStorageProxy =
      getItem: (key)-> storage[key] or null
      setItem: (key, value)->
        storage[key] = value
        return
      clear: -> storage = {}

  window.localStorageProxy = localStorageProxy

  # simplified API to store boolean settings locally
  window.localStorageBool =
    # take care of parsing the boolean string:
    # anything else than the string 'true' will be considered false
    get: (key)-> localStorageProxy.getItem(key) is 'true'
    set: localStorageProxy.setItem.bind(localStorageProxy)

  # Generate a minimalist API from a key
  # someSetting = localStorageBoolApi 'some-setting'
  # someSetting.get()
  # => true / false
  # someSetting.set(true) / someSetting.set(false)
  # => undefined
  window.localStorageBoolApi = (key)->
    get: -> localStorageBool.get key
    set: (bool)-> localStorageBool.set key, bool
