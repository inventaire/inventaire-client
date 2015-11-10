# wrapping model updates to recover the previous value on fails

error_ = require 'lib/error'

# - model:
# pass a unique model at the updater definition
# (ex: to update the mainUser: app.user)
# or pass it in the options at every updates
# (ex: to update one of the groups the main user is admin of)

Updater = (fixedOptions)->
  { endpoint, action, uniqueModel, modelIdLabel } = fixedOptions
  return updater = (options)->
    { model, attribute, value, defaultPreviousValue, selector } = options
    previousValue = app.user.get(attribute) or defaultPreviousValue

    # smooths different ways to set a value to null or undefined
    bothInexistant = (not value?) and (not previousValue?)

    if bothInexistant or _.isEqual value, previousValue
      _.log options, 'the model is already up-to-date'
      promise = _.preq.resolve()
    else
      model or= uniqueModel
      model.set attribute, value

      # preparing options for possible rollback
      options.previousValue = previousValue
      options.model = model

      body =
        attribute: attribute
        value: value

      if action? then body.action = action
      if modelIdLabel? then body[modelIdLabel] = model.id

      promise = _.preq.put endpoint, body
      .catch rollbackUpdate.bind(null, options)

    if selector?
      app.request 'waitForCheck',
        promise: promise
        selector: selector

    return promise


rollbackUpdate = (options, err)->
  { model, attribute, previousValue, selector } = options
  if previousValue?
    _.warn previousValue, "reversing #{attribute} update"
    model.set attribute, previousValue
  else
    _.warn previousValue, "couldn't reverse update: previousValue not found"

  err = if selector? then error_.complete(selector, err) else err
  throw err

module.exports =
  Updater: Updater
