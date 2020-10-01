// wrapping model updates to recover the previous value on fails

import error_ from 'lib/error'

// - model:
// pass a unique model at the updater definition
// (ex: to update the mainUser: app.user)
// or pass it in the options at every updates
// (ex: to update one of the groups the main user is admin of)

const Updater = function (fixedOptions) {
  const { endpoint, action, uniqueModel, modelIdLabel } = fixedOptions
  return options => {
    let promise
    let { model, attribute, value, defaultPreviousValue, selector } = options
    if (!model) { model = uniqueModel }
    let previousValue = model.get(attribute)
    // previousValue can't be defined with a "or":
    // previousValue = model.get(attribute) or defaultPreviousValue
    // as the value might be false and thus use the default value despite being defined
    if (previousValue == null) { previousValue = defaultPreviousValue }

    // smooths different ways to set a value to null or undefined
    const bothInexistant = ((value == null)) && ((previousValue == null))

    if (bothInexistant || _.isEqual(value, previousValue)) {
      _.log(options, 'the model is already up-to-date')
      promise = Promise.resolve()
    } else {
      model.set(attribute, value)

      // preparing options for possible rollback
      options.previousValue = previousValue
      options.model = model

      const body = {
        attribute,
        value
      }

      if (action != null) { body.action = action }
      if (modelIdLabel != null) { body[modelIdLabel] = model.id }

      promise = _.preq.put(endpoint, body)
      .then(applyHookUpdates(model))
      .tap(ConfirmUpdate(model, attribute, value))
      .catch(rollbackUpdate.bind(null, options))
    }

    if (selector != null) {
      app.request('waitForCheck', {
        promise,
        selector
      })
    }

    return promise
  }
}

// Updating an attributes may trigger other attributes to be updated
// which are then passed in the server response as an 'udpate' object
// Ex: group 'name' update triggers an update of the 'slug'
const applyHookUpdates = model => function (updateRes) {
  const { update } = updateRes
  if (_.isNonEmptyPlainObject(update)) { return model.set(update) }
}

// trigger events when the server confirmed the change
const ConfirmUpdate = (model, attribute, value) => () => {
  model.trigger('confirmed', attribute, value)
  model.trigger(`confirmed:${attribute}`, value)
}

const rollbackUpdate = function (options, err) {
  const { model, attribute, previousValue, selector } = options
  if (previousValue != null) {
    _.warn(previousValue, `reversing ${attribute} update`)
    model.set(attribute, previousValue)
    model.trigger('rollback')
  } else {
    _.warn(previousValue, "couldn't reverse update: previousValue not found")
  }

  err = (selector != null) ? error_.complete(err, selector) : err
  throw err
}

export { Updater }
