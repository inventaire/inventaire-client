// client-specific utils
import local_ from 'lib/utils'
import loggers_ from 'lib/loggers'
import types_ from 'lib/types'
import booleanTests_ from 'lib/boolean_tests'

export default () => {
  // _ starts as a global object with just the underscore lib
  // It needs to be explicitly definied hereafter to avoid
  // the variable _ to be overriden in this scope
  const { _ } = window

  _.extend(_, local_, types_, booleanTests_, loggers_)

  return _
}
