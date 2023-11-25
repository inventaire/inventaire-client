import {
  getEntitiesAttributesByUris, getYearFromSimpleDay,
  byNewestPublicationDate, byPopularity, bySerieOrdinal, byItemsOwnersCount
} from '#entities/lib/entities'
import { propertiesEditorsConfigs } from '#entities/lib/properties'
import { I18n } from '#user/lib/i18n'
import { intersection, pluck, uniq } from 'underscore'

export function isSubEntitiesType (type) {
  return [ 'serie', 'collection' ].includes(type)
}

export function getWorksFacets ({ works, context }) {
  const contextProperties = facetsProperties[context]
  const { facets, facetsSelectedValues } = initialize({ contextProperties })

  const valuesUris = []
  works.forEach(setWorkFacets({ facets, valuesUris, contextProperties }))
  removeFacetsWithNoKnownValue(facets)
  return { valuesUris: uniq(valuesUris), facets, facetsSelectedValues }
}

export async function getFacetsEntitiesBasicInfo (facetsObj) {
  const { valuesUris, facets } = facetsObj
  const facetsEntitiesBasicInfo = await getBasicInfo(valuesUris)
  const facetsSelectors = getSelectorsOptions({ facets, facetsEntitiesBasicInfo })
  return { ...facetsObj, facetsEntitiesBasicInfo, facetsSelectors }
}

const initialize = ({ contextProperties }) => {
  const facets = {}
  const facetsSelectedValues = {}

  contextProperties.forEach(property => {
    facets[property] = {}
    facetsSelectedValues[property] = 'all'
  })

  return { facets, facetsSelectedValues }
}

const setWorkFacets = ({ facets, valuesUris, contextProperties }) => work => {
  const { uri, claims } = work
  for (const property of contextProperties) {
    const propertyClaims = claims[property]
    if (propertyClaims) {
      for (let value of propertyClaims) {
        if (valueFormatters[property]) value = valueFormatters[property](value)
        facets[property][value] = facets[property][value] || []
        facets[property][value].push(uri)
      }
      if (entityProperties.includes(property)) {
        valuesUris.push(...propertyClaims)
      }
    } else {
      facets[property].unknown = facets[property].unknown || []
      facets[property].unknown.push(uri)
    }
  }
}

const removeFacetsWithNoKnownValue = facets => {
  for (const [ prop, facet ] of Object.entries(facets)) {
    if (notOnlyUnknownKey(facet)) delete facets[prop]
  }
}

const notOnlyUnknownKey = facet => facet.unknown && Object.keys(facet).length === 1

const getSelectorsOptions = ({ facets, facetsEntitiesBasicInfo }) => {
  const facetsSelectors = {}
  for (const [ property, worksUrisPerValue ] of Object.entries(facets)) {
    const facetSelector = {
      options: [
        { value: 'all', text: I18n('all') },
        ...getOptions({ property, worksUrisPerValue, facetsEntitiesBasicInfo })
      ]
    }
    facetsSelectors[property] = facetSelector
  }
  return facetsSelectors
}

const getOptions = ({ property, worksUrisPerValue, facetsEntitiesBasicInfo }) => {
  const sortFn = customPropertySort[property] || byCount
  return Object.keys(worksUrisPerValue)
  .map(formatOption({ property, worksUrisPerValue, facetsEntitiesBasicInfo }))
  .sort(sortFn)
}

async function getBasicInfo (uris) {
  uris = uniq(uris)
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'labels', 'image' ],
    lang: app.user.lang
  })
  Object.values(entities).forEach(entity => {
    const { labels } = entity
    if (labels) entity.label = Object.values(labels)[0]
  })
  return entities
}

const claimProperties = [
  'wdt:P50',
  'wdt:P136',
  'wdt:P921',
  'wdt:P577',
]

const authorsFacetsProps = [
  'wdt:P50', // author
  'wdt:P110', // illustrator
  'wdt:P58', // scenarist
  'wdt:P6338', // colorist
]

const workProperties = [
  ...authorsFacetsProps,
  'wdt:P110',
  'wdt:P136',
  'wdt:P921',
  'wdt:P577',
]

const humanProperties = [
  'wdt:P136',
  'wdt:P921',
  'wdt:P577',
]

const facetsProperties = {
  author: humanProperties,
  human: humanProperties,
  work: workProperties,
  serie: workProperties,
  publisher: [
    ...authorsFacetsProps,
    'wdt:P577',
    'wdt:P195',
  ],
  collection: [
    ...authorsFacetsProps,
    'wdt:P123',
    'wdt:P577',
  ],
  genre: claimProperties,
  subject: claimProperties,
  movement: claimProperties,
  article: [
    ...authorsFacetsProps,
    'wdt:P1433', // published in
    'wdt:P577',
    'wdt:P921',
  ],
}

const valueFormatters = {
  'wdt:P577': getYearFromSimpleDay,
}

const byCount = (a, b) => {
  const countDifference = getCount(b) - getCount(a)
  if (countDifference === 0) return alphabetically(a, b)
  else return countDifference
}
const alphabetically = (a, b) => a.text > b.text ? 1 : -1
const getCount = option => option.value === 'unknown' ? -1 : option.count

const chronologically = (a, b) => getYearValue(a) - getYearValue(b)
const getYearValue = option => option.value === 'unknown' ? 3000 : parseInt(option.value)

const customPropertySort = {
  'wdt:P577': chronologically,
}

export const entityProperties = uniq(Object.values(facetsProperties)
  .flat()
  .filter(property => propertiesEditorsConfigs[property].editorType === 'entity'))

const formatOption = ({ property, worksUrisPerValue, facetsEntitiesBasicInfo }) => value => {
  if (entityProperties.includes(property)) {
    return {
      value,
      image: facetsEntitiesBasicInfo[value]?.image?.url,
      text: facetsEntitiesBasicInfo[value]?.label || value,
      count: worksUrisPerValue[value].length
    }
  } else if (property === 'wdt:P577') {
    return {
      value,
      text: value,
      count: worksUrisPerValue[value].length,
    }
  }
}

export function getSelectedUris ({ works, facets, facetsSelectedValues }) {
  let selectedUris = pluck(works, 'uri')
  for (const [ property, selectedValue ] of Object.entries(facetsSelectedValues)) {
    if (selectedValue !== 'all') {
      const matchingUris = facets[property][selectedValue]
      selectedUris = intersection(selectedUris, matchingUris)
    }
  }
  return new Set(selectedUris)
}

export const bySearchMatchScore = textFilterUris => (a, b) => {
  return textFilterUris.indexOf(a.uri) - textFilterUris.indexOf(b.uri)
}

export function isClaimLayout (layoutContext) {
  return [ 'genre', 'subject', 'movement' ].includes(layoutContext)
}

const publicationDateOption = {
  text: 'publication date',
  value: 'byPublicationDate',
  sortFunction: byNewestPublicationDate
}

const popularityOption = {
  text: 'popularity',
  value: 'byPopularity',
  sortFunction: byPopularity
}

const serieOrdinalOption = {
  text: 'serie ordinal',
  value: 'bySerieOrdinal',
  sortFunction: bySerieOrdinal
}

const itemsOwnersCountOption = {
  text: 'users in your network',
  value: 'byItemsOwnersCount',
  sortFunction: byItemsOwnersCount
}

// Sorting options order matters
// as first option will be selected by default
let sortingFunctionByNameByType = {
  edition: {
    byPopularity: popularityOption,
    byPublicationDate: publicationDateOption,
    byItemsOwnersCount: itemsOwnersCountOption
  },
  work: {
    byPublicationDate: publicationDateOption,
    byPopularity: popularityOption,
  },
  seriePart: {
    bySerieOrdinal: serieOrdinalOption,
    byPublicationDate: publicationDateOption,
    byPopularity: popularityOption,
  },
}

export const getSortingOptionsByName = type => {
  return sortingFunctionByNameByType[type]
}
