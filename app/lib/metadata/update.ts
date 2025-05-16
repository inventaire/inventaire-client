// Metadata update is coupled to the needs of:
// - Browsers:
//   - document title update (which is important for the browser history)
//   - RSS feed detection
// - Prerender (https://git.inventaire.io/firefox-headless-prerender), which itself aims to serve:
//   - search engines need status codes and redirection locations
//   - social media need metadata in different formats to show link previews:
//     - opengraph (https://ogp.me)
//     - twitter cards (https://developer.twitter.com/cards)
//   - other crawlers
import { writable } from 'svelte/store'
import { API } from '#app/api/api'
import { dropLeadingSlash, objectEntries } from '#app/lib/utils'
import type { RelativeUrl, Url } from '#server/types/common'
import { i18n } from '#user/lib/i18n'
import { getOngoingRequestsCount } from '../preq.ts'
import { applyTransformers, transformers } from './apply_transformers.ts'
import type { ProjectRootRelativeUrl } from '../location.ts'

export const isPrerenderSession = (window.navigator?.userAgent.match('Prerender') != null)

interface Metadata {
  url: string
  title: string
  description: string
  image: Url
  rss: Url
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

export async function updateRouteMetadata (route: RelativeUrl | ProjectRootRelativeUrl, metadataPromise: MetadataUpdate | Promise<MetadataUpdate> = {}) {
  route = dropLeadingSlash(route)
  // metadataPromise can be a promise or a simple object
  const metadata = await metadataPromise
  if (Object.keys(metadata).length === 0) return
  applyMetadataUpdate(route, metadata)
  if (metadata?.title) metadataUpdateDone()
}

export function getDefaultMetadata () {
  return {
    url: '',
    title: 'Inventaire - ' + i18n('your friends and communities are your best library'),
    description: i18n('Make the inventory of your books, share it with your friends and communities into an infinite library!'),
    image: '/public/images/inventaire-books.jpg' as Url,
    rss: 'https://mamot.fr/users/inventaire.rss' as Url,
    'og:type': 'website' as const,
    'twitter:card': 'summary_large_image' as const,
  } as Metadata
}

export const metadataStore = writable(null)

function applyMetadataUpdate (route: ProjectRootRelativeUrl, metadataUpdate: MetadataUpdate = {}) {
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

  for (const [ key, value ] of objectEntries(metadata)) {
    if (value) {
      // @ts-expect-error
      metadata[key] = applyTransformers(key, value)
    }
  }
  metadataStore.set(metadata)
}

export function clearMetadata () {
  resetPagePrerender()
  metadataStore.set(getDefaultMetadata())
  prerenderStatusStore.set({})
}

let sessionId = 0
let endPrerenderSession
function resetPagePrerender () {
  if (!isPrerenderSession) return
  const currentSessionId = ++sessionId
  // Setting window.prerenderReady is required by firefox-headless-prerender
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

export const prerenderStatusStore = writable({} as { statusCode?: number, header?: string })

function setPrerenderMeta (statusCode = 500, route: ProjectRootRelativeUrl) {
  if (!isPrerenderSession || window.prerenderReady) return

  if (statusCode === 302 && route != null) {
    const fullUrl = transformers.url(route)
    // See https://git.inventaire.io/firefox-headless-prerender/blob/599894c/server/get_page_metadata.js
    prerenderStatusStore.set({ statusCode, header: `Location: ${fullUrl}` })
  } else {
    prerenderStatusStore.set({ statusCode })
  }
}

export function setPrerenderStatusCode (statusCode: number, route?: ProjectRootRelativeUrl) {
  setPrerenderMeta(statusCode, route)
  metadataUpdateDone()
}
