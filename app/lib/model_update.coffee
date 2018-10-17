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
    model or= uniqueModel
    previousValue = model.get attribute
    # previousValue can't be defined with a "or":
    # previousValue = model.get(attribute) or defaultPreviousValue
    # as the value might be false and thus use the default value despite being defined
    previousValue ?= defaultPreviousValue

    # smooths different ways to set a value to null or undefined
    bothInexistant = (not value?) and (not previousValue?)

    if bothInexistant or _.isEqual(value, previousValue)
      _.log options, 'the model is already up-to-date'
      promise = _.preq.resolved
    else
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
      .then applyHookUpdates(model)
      .tap ConfirmUpdate(model, attribute, value)
      .catch rollbackUpdate.bind(null, options)

    if selector?
      app.request 'waitForCheck',
        promise: promise
        selector: selector

    return promise

# Updating an attributes may trigger other attributes to be updated
# which are then passed in the server response as an 'udpate' object
# Ex: group 'name' update triggers an update of the 'slug'
applyHookUpdates = (model)-> (updateRes)->
  { update } = updateRes
  if _.isNonEmptyPlainObject(update) then model.set update

# trigger events when the server confirmed the change
ConfirmUpdate = (model, attribute, value)->
  return confirm = ->
    model.trigger 'confirmed', attribute, value
    model.trigger "confirmed:#{attribute}", value

rollbackUpdate = (options, err)->
  { model, attribute, previousValue, selector } = options
  if previousValue?
    _.warn previousValue, "reversing #{attribute} update"
    model.set attribute, previousValue
    model.trigger 'rollback'
  else
    _.warn previousValue, "couldn't reverse update: previousValue not found"

  err = if selector? then error_.complete(err, selector) else err
  throw err

module.exports = { Updater }
