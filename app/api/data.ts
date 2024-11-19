import { config } from '#app/config'
import { fixedEncodeURIComponent, forceArray } from '#app/lib/utils'
import { getEndpointPathBuilders } from './endpoint.ts'

const { remoteEntitiesOrigin } = config

const { action } = getEndpointPathBuilders('data', remoteEntitiesOrigin)

export default {
  wikipediaExtract (lang, title) {
    title = fixedEncodeURIComponent(title)
    return action('wp-extract', { lang, title })
  },
  isbn (isbn) {
    return action('isbn', { isbn })
  },
  summaries: ({ uri, langs, refresh }) => {
    langs = forceArray(langs).join('|')
    return action('summaries', { uri, langs, refresh })
  },
  propertyValues: action('property-values'),
  properties: action('properties'),
}
