# behaviors: Loading MUST be added to the view
# elements required in the view: .loading
# startLoading / stopLoading MUST NOT be called at view initialization
# but rathen onShow/onRender so that the expected DOM elements are rendered
loading_ =
  startLoading: (options)->
    if _.isString(options) then options = {selector: options}
    @$el.trigger 'loading', options
  stopLoading: -> @$el.trigger 'stopLoading'

# behaviors: SuccessCheck MUST be added to the view
# elements required in the view: .checkWrapper > .check
successCheck_ =
  check: (label, cb, res)->
    @$el.trigger 'check', cb
    if label? and res? then _.log res, label

  fail: (label, cb, err)->
    @$el.trigger 'fail', cb
    if label? and err? then _.error err, label

successCheck_.Check = (label, cb)-> successCheck_.check.bind(@, label, cb)
successCheck_.Fail = (label, cb)-> successCheck_.fail.bind(@, label, cb)

# behaviors: AlertBox MUST be added to the view
alert_ =
  alert: (message)->
    console.warn(message)
    @$el.trigger 'alert', { message: _.i18n(message) }
    return

# typical invocation: _.extend @, behaviorsPlugin
# ( and not behaviorsPlugin.call @ )
# allows to call functions only when needed: behaviorsPlugin.startLoading.call(@)
module.exports = _.extend {}, loading_, successCheck_, alert_
