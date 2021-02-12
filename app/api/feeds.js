import { buildPath } from 'lib/location'
import endpoint from './endpoint'
const feedEndpointBase = endpoint('feeds', true)

export default function (key, id) {
  // Always using the absolute path so that links are treated as external links,
  // thus getting target='_blank' attributes, and the associated click behaviors
  // cf app/modules/general/lib/smart_prevent_default.js
  // Set feedEndpoint inside the function as window.location.root is set by init_app
  const feedEndpoint = `${window.location.root}${feedEndpointBase}`

  const query = {}
  query[key] = id
  if (app.user.loggedIn) {
    query.requester = app.user.id
    query.token = app.user.get('readToken')
  }

  return buildPath(feedEndpoint, query)
}
