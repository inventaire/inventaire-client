import { inspect } from 'node:util'

export const shouldNotBeCalled = res => {
  console.warn(inspect(res, false, null), 'undesired positive res')
  const err = new Error('function was expected not to be called')
  Object.assign(err, {
    // Give 'shouldNotBeCalled' more chance to appear in the red text of the failing test
    name: 'shouldNotBeCalled',
    statusCode: 'shouldNotBeCalled',
    body: { status_verbose: 'shouldNotBeCalled' },
    context: { res },
  })
  throw err
}
