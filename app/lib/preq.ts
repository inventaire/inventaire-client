import app from '#app/app'
import { newError, type ContextualizedError } from '#app/lib/error'
import type { Url } from '#server/types/common'

type Method = 'get' | 'post' | 'put' | 'delete'
interface Options {
  method: Method
  body?: string
  headers?: { 'content-type': 'application/json' }
}

let ongoingRequestsCount = 0
function ajaxFactory (method, hasBody) {
  return async function request (url: Url, body?: unknown) {
    const options: Options = { method }

    if (hasBody) {
      options.body = JSON.stringify(body)
      // Do not set content type on cross origin requests as it triggers preflight checks
      // cf https://stackoverflow.com/a/12320736/3324977
      if (url[0] === '/') options.headers = { 'content-type': 'application/json' }
    }

    let res, responseText, responseJSON
    try {
      ongoingRequestsCount++
      res = await fetch(url, options)
      responseText = await res.text()
      // Known case starting with "{": /api/*, wiki*.org answers
      // Known case starting with "[": nominatim
      if (responseText && (responseText[0] === '{' || responseText[0] === '[')) responseJSON = JSON.parse(responseText)
    } catch (err) {
      err.context = Object.assign({ url }, options)
      throw err
    } finally {
      ongoingRequestsCount--
    }

    const { status: statusCode } = res
    if (statusCode && statusCode < 400) {
      return responseJSON
    } else {
      let message
      const statusText = res?.statusText
      if (statusCode && statusCode >= 400) {
        const messageWithContext = `${statusCode}: ${statusText} - ${responseText} - ${url}`
        // We need a clean message in case this is to be displayed as an alert
        message = responseJSON?.status_verbose || messageWithContext
      } else if (statusCode === 0) {
        app.execute('flash:message:show:network:error')
        message = 'network error'
      } else {
        // cf https://stackoverflow.com/a/6186905
        // Known case: request blocked by CORS headers
        message = `parsing error: ${method} ${url}
    got statusCode ${statusCode} but invalid JSON: ${responseText} / ${responseJSON}`
      }
      const error = newError(message)
      error.serverError = true
      Object.assign(error, { statusCode, statusText, responseText, responseJSON, context: options })
      throw error
    }
  }
}

const preq = {
  get: ajaxFactory('GET', false),
  post: ajaxFactory('POST', true),
  put: ajaxFactory('PUT', true),
  delete: ajaxFactory('DELETE', false),
}

/** Typed HTTP requests */
export const treq = {
  get: async function <Response> (url): Promise<Response> {
    return preq.get(url)
  },
}

// TODO: delete once Backbone models and collections are fully removed
// @ts-expect-error
preq.wrap = (jqPromise, context) => new Promise((resolve, reject) => {
  jqPromise
  .then(resolve)
  .fail(err => reject(rewriteJqueryError(err, context)))
})

export default preq

function rewriteJqueryError (err: ContextualizedError, context: Record<string, unknown>) {
  let message
  // @ts-expect-error
  const { status: statusCode, statusText, responseText, responseJSON } = err
  const { url, type: verb } = context
  if (statusCode >= 400) {
    const messageWithContext = `${statusCode}: ${statusText} - ${responseText} - ${url}`
    // We need a clean message in case this is to be displayed as an alert
    message = responseJSON?.status_verbose || messageWithContext
  } else if (statusCode === 0) {
    app.execute('flash:message:show:network:error')
    message = 'network error'
  } else {
    // cf https://stackoverflow.com/a/6186905
    // Known case: request blocked by CORS headers
    message = `parsing error: ${verb} ${url}
got statusCode ${statusCode} but invalid JSON: ${responseText} / ${responseJSON}`
  }

  const error = new Error(message)
  // @ts-expect-error
  error.serverError = true
  return Object.assign(error, { statusCode, statusText, responseText, responseJSON, context })
}

export function getOngoingRequestsCount () {
  return ongoingRequestsCount
}
