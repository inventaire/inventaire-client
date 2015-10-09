Promise = require 'bluebird'

Promise.onPossiblyUnhandledRejection (err)->
  _.error err, 'PossiblyUnhandledRejection'
  throw err

# /!\ providing promises in place to client tests,
# thus faking jQuery
Promise::fail = Promise::caught

bluereq = require 'bluereq'

module.exports =
  get: (url)-> bluereq.get(url).then (res)-> res.body
  post: (params)-> bluereq.post(params).then (res)-> res.body

  Promise: Promise
  reject: Promise.reject.bind(Promise)
  resolve: Promise.resolve.bind(Promise)
