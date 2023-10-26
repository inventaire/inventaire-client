import { isNonEmptyString } from '#lib/boolean_tests'
import { buildPath } from '#lib/location'
const formAction = '/api/submit'

export function prepareRedirect (redirect) {
  redirect = redirect || app.request('querystring:get', 'redirect')

  if (!isNonEmptyString(redirect)) return formAction

  if (redirect[0] === '/') redirect = redirect.slice(1)

  // Required for redirections including query strings
  // Known case: redirections to /authorize during OAuth workflows
  redirect = encodeURIComponent(redirect)

  return buildPath(formAction, { redirect })
}
