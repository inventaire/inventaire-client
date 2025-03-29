import { API } from '#app/api/api'
import app from '#app/app'
import { config } from '#app/config'
import { dropLeadingSlash } from '#app/lib/utils'
import type { AbsoluteUrl, Url } from '#server/types/common'
import { getQuerystringParameter } from '../querystring_helpers'

const { instanceName } = config
const { origin } = location

function absolutePath (url: Url) {
  if (url?.[0] === '/') {
    return origin + url
  } else {
    return url
  }
}

export function applyTransformers (key: string, value: unknown) {
  if (transformers[key] != null) {
    return transformers[key](value)
  } else {
    return value
  }
}

export const transformers = {
  title: (value: string) => {
    return value.endsWith(instanceName) ? value : `${value} - ${instanceName}`
  },
  url: (canonicalPath: string) => {
    canonicalPath = dropLeadingSlash(canonicalPath)
    let url = `${window.location.origin}/${canonicalPath}`

    // Preserve parameters that make a resource different enough,
    // that the prerendered version returned should be different
    const lang = getQuerystringParameter('lang') || app.user?.lang || 'en'
    url += `?lang=${lang}`

    return url as AbsoluteUrl
  },
  image: url => {
    if (url.match(/\d+x\d+/)) {
      return absolutePath(url)
    } else {
      return absolutePath(API.img(url))
    }
  },
}
