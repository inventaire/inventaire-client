import { API } from '#app/api/api'
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
import { dropLeadingSlash } from '#app/lib/utils'
import type { Url } from '#server/types/common'
import { i18n } from '#user/lib/i18n'
import { getOngoingRequestsCount } from '../preq.ts'
import { transformers } from './apply_transformers.ts'
import updateNodeType from './update_node_type.ts'

export const isPrerenderSession = (window.navigator?.userAgent.match('Prerender') != null)

interface Metadata {
  url: string
  title: string
  description: string
  image: Url
  rss: Url
  'og:type'?: 'website'
  'twitter:card': 'summary' | 'summary_large_image'
}

export interface MetadataUpdate {
  url?: string
  title?: string
  description?: string
  image?: Url
  smallCardType?: boolean
  'twitter:card'?: 'summary' | 'summary_large_image'
  rss?: Url
}

export async function updateRouteMetadata (route, metadataPromise: MetadataUpdate | Promise<MetadataUpdate> = {}) {
  route = dropLeadingSlash(route)
  // metadataPromise can be a promise or a simple object
  const metadata = await metadataPromise
  if (Object.keys(metadata).length === 0) return
  applyMetadataUpdate(route, metadata)
  if (metadata?.title) metadataUpdateDone()
}

function applyMetadataUpdate (route, metadataUpdate: MetadataUpdate = {}) {
  if (metadataUpdate.smallCardType) {
    metadataUpdate['twitter:card'] = 'summary'
    // Use a small image to force social media to display it small
    metadataUpdate.image = (metadataUpdate.image != null) ? API.img(metadataUpdate.image, 300, 300) : undefined
  }
  let metadata: Metadata
  if (metadataUpdate.title == null) {
    metadata = getDefaultMetadata()
  } else {
    const { url, title, description, image, rss, 'twitter:card': twitterCard } = metadataUpdate
    metadata = { url, title, description, image, rss, 'twitter:card': twitterCard }
  }
  if (!metadata.url) metadata.url = `/${route}`
  // image and rss can keep the default value, but description should be empty if no specific description can be found
  // to avoid just spamming with the default description
  if (metadata.description == null) metadata.description = ''
  updateMetadata(metadata)
}

export const getDefaultMetadata = () => ({
  url: '',
  title: 'Inventaire - ' + i18n('your friends and communities are your best library'),
  description: i18n('Make the inventory of your books, share it with your friends and communities into an infinite library!'),
  image: 'https://inventaire.io/public/images/inventaire-books.jpg' as Url,
  rss: 'https://mamot.fr/users/inventaire.rss' as Url,
  'og:type': 'website' as const,
  'twitter:card': 'summary_large_image' as const,
})

function updateMetadata (metadata) {
  for (const key in metadata) {
    const value = metadata[key]
    updateNodeType(key, value)
  }
}

export function clearMetadata () {
  resetPagePrerender()
  updateMetadata(getDefaultMetadata())
  $('head meta[name^="prerender"]').remove()
}

let sessionId = 0
let endPrerenderSession
function resetPagePrerender () {
  if (!isPrerenderSession) return
  const currentSessionId = ++sessionId
  window.prerenderReady = false
  endPrerenderSession = () => {
    // Stop waiting once the session is idle: addresses cases
    // where metadataUpdateDone would not have been called
    if (sessionId === currentSessionId && !window.prerenderReady) {
      if (getOngoingRequestsCount() === 0) {
        console.log('assume page prerendering is over')
        window.prerenderReady = true
      } else {
        console.log('ongoing requests: wait for page prerendering')
        setTimeout(endPrerenderSession, 200)
      }
    }
  }
  setTimeout(endPrerenderSession, 5000)
}

resetPagePrerender()

async function metadataUpdateDone () {
  if (!isPrerenderSession) return
  console.log('metadata update done')
  endPrerenderSession?.()
}

function setPrerenderMeta (statusCode = 500, route) {
  if (!isPrerenderSession || window.prerenderReady) return

  let prerenderMeta = `<meta name='prerender-status-code' content='${statusCode}'>`
  if (statusCode === 302 && route != null) {
    const fullUrl = transformers.url(route)
    // See https://github.com/prerender/prerender#httpheaders
    prerenderMeta += `<meta name='prerender-header' content='Location: ${fullUrl}'>`
  }

  $('head').append(prerenderMeta)
}

export function setPrerenderStatusCode (statusCode, route?) {
  setPrerenderMeta(statusCode, route)
  metadataUpdateDone()
}
