// client-specific utils
import local_ from 'lib/utils'
import loggers_ from 'lib/loggers'
import types_ from 'lib/types'
import booleanTests_ from 'lib/boolean_tests'
import preq from 'lib/preq'
import isMobile from 'lib/mobile_check'

export default () => {
  // http requests handler returning promises
  _.preq = preq
  _.isMobile = isMobile
  // _ starts as a global object with just the underscore lib
  // It needs to be explicitly definied hereafter to avoid
  // the variable _ to be overriden in this scope
  const { _ } = window

  _.extend(_, local_, types_, booleanTests_, loggers_)

  return _
}
