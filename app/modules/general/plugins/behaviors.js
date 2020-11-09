import log_ from 'lib/loggers'
import { i18n } from 'modules/user/lib/i18n'
// behaviors: Loading MUST be added to the view
// elements required in the view: .loading
// startLoading / stopLoading MUST NOT be called at view initialization
// but rathen onShow/onRender so that the expected DOM elements are rendered
export function startLoading (params) {
  if (_.isString(params)) params = { selector: params }
  this.$el.trigger('loading', params)
}

export function stopLoading (params) {
  if (_.isString(params)) params = { selector: params }
  this.$el.trigger('stopLoading', params)
}

// behaviors: SuccessCheck MUST be added to the view
// elements required in the view: .checkWrapper > .check
export function check (label, cb, res) {
  this.$el.trigger('check', cb)
  if (label != null && res != null) return log_.info(res, label)
}

export function fail (label, cb, err) {
  this.$el.trigger('fail', cb)
  if (label != null && err != null) return log_.error(err, label)
}

export const Check = function (label, cb) {
  return check.bind(this, label, cb)
}

export const Fail = function (label, cb) {
  return fail.bind(this, label, cb)
}

// behaviors: AlertBox MUST be added to the view
export function alert (message) {
  console.warn(message)
  this.$el.trigger('alert', { message: i18n(message) })
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
