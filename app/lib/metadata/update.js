// Metadata update is coupled to the needs of:
// - Browsers:
//   - document title update (which is important for the browser history)
//   - RSS feed detection
// - Prerender (https://github.com/inventaire/prerender), which itself aims to serve:
//   - search engines need status codes and redirection locations
//   - social media need metadata in different formats to show link previews:
//     - opengraph (https://ogp.me)
//     - twitter cards (https://developer.twitter.com/cards)
//   - other crawlers
//
// For all the needs covered by Prerender, only the first update matters,
// but further updates might be needed for in browser metadata access,
// such as RSS feed detections

import updateNodeType from './update_node_type'
import { I18n, i18n } from 'modules/user/lib/i18n'
import { transformers } from './apply_transformers'

const initialFullPath = location.pathname.slice(1) + location.search
// Make prerender wait before assuming everything is ready
// see https://prerender.io/documentation/best-practices
window.prerenderReady = false
const metadataUpdateDone = () => { window.prerenderReady = true }
// Stop waiting if it takes more than 20 secondes: addresses cases
// where metadataUpdateDone would not have been called
setTimeout(metadataUpdateDone, 20 * 1000)
const isPrerenderSession = (window.navigator.userAgent.match('Prerender') != null)

let lastRoute = null
const updateRouteMetadata = async (route, metadataPromise = {}) => {
  route = route.replace(/^\//, '')
  // There should be no need to re-update metadata when the route stays the same
  if (lastRoute === route) return
  lastRoute = route

  // metadataPromise can be a promise or a simple object
  const metadata = await metadataPromise
  applyMetadataUpdate(route, metadata)
  metadataUpdateDone()
}

const applyMetadataUpdate = (route, metadata = {}) => {
  let redirection
  const targetFullPath = route + location.search
  if (!prerenderReady && initialFullPath !== targetFullPath) redirection = true

  if (redirection) setPrerenderMeta(302, route)

  if (metadata.smallCardType) {
    metadata['twitter:card'] = 'summary'
    // Use a small image to force social media to display it small
    metadata.image = (metadata.image != null) ? app.API.img(metadata.image, 300, 300) : undefined
    delete metadata.smallCardType
  }

  if (metadata.title == null) metadata = defaultMetadata()
  if (!metadata.url) metadata.url = `/${route}`
  // image and rss can keep the default value, but description should be empty if no specific description can be found
  // to avoid just spamming with the default description
  if (metadata.description == null) metadata.description = ''
  updateMetadata(metadata)
}

const defaultMetadata = () => ({
  title: 'Inventaire - ' + i18n('your friends and communities are your best library'),
  description: I18n('make the inventory of your books and mutualize with your friends and communities into an infinite library!'),
  image: 'https://inventaire.io/public/images/inventaire-books.jpg',
  rss: 'https://mamot.fr/users/inventaire.rss',
  'og:type': 'website',
  'twitter:card': 'summary_large_image'
})

const updateMetadata = function (metadata) {
  for (const key in metadata) {
    const value = metadata[key]
    updateNodeType(key, value)
  }
}

const setPrerenderMeta = function (statusCode = 500, route) {
  if (!isPrerenderSession || prerenderReady) return

  let prerenderMeta = `<meta name='prerender-status-code' content='${statusCode}'>`
  if (statusCode === 302 && route != null) {
    const fullUrl = transformers.url(route)
    // See https://github.com/prerender/prerender#httpheaders
    prerenderMeta += `<meta name='prerender-header' content='Location: ${fullUrl}'>`
  }

  $('head').append(prerenderMeta)
}

const setPrerenderStatusCode = function (statusCode, route) {
  setPrerenderMeta(statusCode, route)
  metadataUpdateDone()
}

export { updateRouteMetadata, setPrerenderStatusCode }
