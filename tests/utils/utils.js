import { inspect } from 'util'

export const shouldNotBeCalled = res => {
  console.warn(inspect(res, false, null), 'undesired positive res')
  const err = new Error('function was expected not to be called')
  // Give 'shouldNotBeCalled' more chance to appear in the red text of the failing test
  err.name = err.statusCode = 'shouldNotBeCalled'
  err.body = { status_verbose: 'shouldNotBeCalled' }
  err.context = { res }
  throw err
}
