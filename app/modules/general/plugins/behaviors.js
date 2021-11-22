import log_ from 'lib/loggers'
import { i18n } from 'modules/user/lib/i18n'
import error_ from 'lib/error'

// behaviors: Loading MUST be added to the view
// elements required in the view: .loading
// startLoading / stopLoading MUST NOT be called at view initialization
// but rathen onRender so that the expected DOM elements are rendered
export function startLoading (params) {
  assertViewHasBehavior(this, 'Loading')
  if (_.isString(params)) params = { selector: params }
  this.$el.trigger('loading', params)
}

export function stopLoading (params) {
  assertViewHasBehavior(this, 'Loading')
  if (_.isString(params)) params = { selector: params }
  this.$el.trigger('stopLoading', params)
}

// behaviors: SuccessCheck MUST be added to the view
// elements required in the view: .checkWrapper > .check
export function check (label, cb, res) {
  assertViewHasBehavior(this, 'SuccessCheck')
  this.$el.trigger('check', cb)
  if (label != null && res != null) return log_.info(res, label)
}

export function fail (label, cb, err) {
  assertViewHasBehavior(this, 'SuccessCheck')
  this.$el.trigger('fail', cb)
  if (label != null && err != null) return log_.error(err, label)
}

export const Check = function (label, cb) {
  assertViewHasBehavior(this, 'SuccessCheck')
  return check.bind(this, label, cb)
}

export const Fail = function (label, cb) {
  assertViewHasBehavior(this, 'SuccessCheck')
  return fail.bind(this, label, cb)
}

// behaviors: AlertBox MUST be added to the view
export function alert (message) {
  assertViewHasBehavior(this, 'AlertBox')
  console.warn(message)
  this.$el.trigger('alert', { message: i18n(message) })
}

const shouldAssertThatViewsHaveBehaviors = window.env === 'dev'

// assertViewHasBehavior can be used for behavior classes
// where the behaviorName attribute is set
export const assertViewHasBehavior = function (view, name) {
  if (!shouldAssertThatViewsHaveBehaviors) return
  // When the view has no behavior, view._behaviors is an empty object
  if (view._behaviors instanceof Array) {
    for (const behavior of view._behaviors) {
      if (behavior.behaviorName === name) return
    }
  }
  throw error_.new(`view misses behavior: ${name}`, 500)
}

// typical invocation: _.extend @, behaviorsPlugin
// ( and not behaviorsPlugin.call @ )
// allows to call functions only when needed: behaviorsPlugin.startLoading.call(@)
export default {
  startLoading,
  stopLoading,
  check,
  fail,
  Check,
  Fail,
  alert,
}
