import { getLocalStorageStore } from '#lib/components/stores/local_storage_stores'
import { I18n } from '#user/lib/i18n'
import { derived } from 'svelte/store'
import { groupBy } from 'underscore'

export const linksSettings = getLocalStorageStore('settings:display:links', [])

const alphabetically = (a, b) => a.label > b.label ? 1 : -1

export const linkClaimsProperties = [
  { property: 'wdt:P268', label: 'BNF', category: 'bibliographicDatabases' },
  { property: 'wdt:P648', label: 'OpenLibrary', category: 'bibliographicDatabases' },
  { property: 'wdt:P2002', label: 'Twitter', category: 'socialNetworks' },
  { property: 'wdt:P2013', label: 'Facebook', category: 'socialNetworks' },
  { property: 'wdt:P2003', label: 'Instagram', category: 'socialNetworks' },
  { property: 'wdt:P2397', label: 'YouTube', category: 'socialNetworks' },
  { property: 'wdt:P4033', label: 'Mastodon', category: 'socialNetworks' },
]

export const linksClaimsPropertiesByCategory = groupBy(linkClaimsProperties, 'category')

for (const category of Object.keys(linksClaimsPropertiesByCategory)) {
  linksClaimsPropertiesByCategory[category] = linksClaimsPropertiesByCategory[category].sort(alphabetically)
}

export const displayedPropertiesByCategory = derived(linksSettings, $linksSettings => {
  const displayedProperties = linkClaimsProperties.filter(({ property }) => {
    return $linksSettings.includes(property)
  })
  return groupBy(displayedProperties, 'category')
})

export const categoryLabels = {
  bibliographicDatabases: I18n('bibliographic databases'),
  socialNetworks: I18n('social networks'),
}
