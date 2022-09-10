import { I18n } from '#user/lib/i18n'
import { groupBy } from 'underscore'
import { isNonEmptyArray } from '#lib/boolean_tests'

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

export const getDisplayedPropertiesByCategory = () => {
  const customProperties = app.user.get('customProperties')
  if (isNonEmptyArray(customProperties)) {
    const displayedProperties = linkClaimsProperties.filter(({ property }) => {
      return customProperties.includes(property)
    })
    return groupBy(displayedProperties, 'category')
  } else {
    return {}
  }
}

export const categoryLabels = {
  bibliographicDatabases: I18n('bibliographic databases'),
  socialNetworks: I18n('social networks'),
}
