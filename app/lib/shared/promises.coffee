# used has a way to create only one resolved promise to start promise chains
resolved = Object.freeze Promise.resolve()

module.exports = (Promise)->
  resolve: Promise.resolve.bind Promise
  reject: Promise.reject.bind Promise
  resolved: resolved

  # aliases
  start: resolved
