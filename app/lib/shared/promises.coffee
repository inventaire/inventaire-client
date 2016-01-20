# used has a way to create only one resolved promise to start promise chains
resolved = Object.freeze Promise.resolve()

module.exports = (Promise)->
  resolve: Promise.resolve.bind Promise
  reject: Promise.reject.bind Promise
  resolved: resolved

  # used to start a promise chain
  # allowing the first functions of the chain
  # to return a promise or not and still be able
  # to follow it by .then and .catch
  start: resolved
