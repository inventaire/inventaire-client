import { newError } from '#app/lib/error'
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
        showNetworkError()
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
  get: async function <Response> (url: Url): Promise<Response> {
    return preq.get(url)
  },
  post: async function <Response> (url: Url, body?: unknown): Promise<Response> {
    return preq.post(url, body)
  },
  put: async function <Response> (url: Url, body?: unknown): Promise<Response> {
    return preq.put(url, body)
  },
  delete: async function <Response> (url: Url): Promise<Response> {
    return preq.delete(url)
  },
}

export default preq

export function getOngoingRequestsCount () {
  return ongoingRequestsCount
}

async function showNetworkError () {
  // Late import to avoid a circular dependency on the '#app/api/api'
  const { default: app } = await import('#app/app')
  app.execute('flash:message:show:network:error')
}
