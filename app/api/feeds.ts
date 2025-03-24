import app from '#app/app'
import { buildPath } from '#app/lib/location'
import type { AbsoluteUrl } from '#server/types/common'
import type { UserId } from '#server/types/user'
import { getEndpointBase } from './endpoint.ts'

const feedEndpointBase = getEndpointBase('feeds')
// Always using the absolute path so that links are treated as external links,
// thus getting target='_blank' attributes, and the associated click behaviors
// cf app/modules/general/lib/smart_prevent_default.js
const feedEndpoint = `${window.location?.origin}${feedEndpointBase}` as AbsoluteUrl

export default function (key, id) {
  const query: { requester?: UserId, token?: string } = {}
  query[key] = id
  if (app.user.loggedIn) {
    query.requester = app.user.id
    query.token = app.user.readToken
  }

  return buildPath(feedEndpoint, query)
}
