loading_ =
  startLoading: (options)->
    if _.isString(options) then options = {selector: options}
    @$el.trigger 'loading', options
  stopLoading: -> @$el.trigger 'stopLoading'

successCheck_ =
  check: (label, cb, res)->
    @$el.trigger 'check', cb
    if label? and res? then _.log res, label

  fail: (label, cb, err)->
    @$el.trigger 'fail', cb
    if label? and err? then _.error err, label

successCheck_.Check = (label, cb)-> successCheck_.check.bind(@, label, cb)
successCheck_.Fail = (label, cb)-> successCheck_.fail.bind(@, label, cb)

alert_ =
  alert: (message)->
    console.warn(message)
    @$el.trigger 'alert', { message: _.i18n(message) }
    return

module.exports = _.extend {}, loading_, successCheck_, alert_
