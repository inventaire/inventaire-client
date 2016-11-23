module.exports = (Promise)->
  # Used has a way to create only one resolved promise to start promise chains.
  # Unfortunatly, this object can't be froozen as it would be incompatible with
  # bluebird cancellable promises.
  # This may register as a premature micro-optimization
  # cf http://stackoverflow.com/q/40683818/3324977
  resolved = Promise.resolve()

  return API =
    resolve: Promise.resolve.bind Promise
    reject: Promise.reject.bind Promise
    resolved: resolved

    # used to start a promise chain
    # allowing the first functions of the chain
    # to return a promise or not and still be able
    # to follow it by .then and .catch
    start: resolved
    # start a promise chain after a delay
    delay: resolved.delay
    try: Promise.try.bind Promise
