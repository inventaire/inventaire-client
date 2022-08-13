import { getEntitiesAttributesByUris, getYearFromSimpleDay } from '#entities/lib/entities'
import properties from '#entities/lib/properties'
import { I18n } from '#user/lib/i18n'
import { intersection, pluck, uniq } from 'underscore'

export async function getWorksFacets (works) {
  const { facets, facetsSelectedValues } = initialize()

  const valuesUris = []
  works.forEach(setWorkFacets({ facets, valuesUris }))

  const facetsEntitiesBasicInfo = await getBasicInfo(valuesUris)

  const facetsSelectors = getSelectorsOptions({ facets, facetsEntitiesBasicInfo })

  return { facets, facetsEntitiesBasicInfo, facetsSelectedValues, facetsSelectors }
}

const initialize = () => {
  const facets = {}
  const facetsSelectedValues = {}

  facetsProperties.forEach(property => {
    facets[property] = {}
    facetsSelectedValues[property] = 'all'
  })

  return { facets, facetsSelectedValues }
}

const setWorkFacets = ({ facets, valuesUris }) => work => {
  const { uri, claims } = work
  for (const property of facetsProperties) {
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

const getSelectorsOptions = ({ facets, facetsEntitiesBasicInfo }) => {
  const facetsSelectors = {}
  for (const [ property, worksUrisPerValue ] of Object.entries(facets)) {
    const facetSelector = {
      options: [
        { value: 'all', text: I18n('all') },
        ...getOptions({ property, worksUrisPerValue, facetsEntitiesBasicInfo })
      ]
    }
    facetSelector.disabled = hasNoKnownValue(facetSelector.options)
    facetsSelectors[property] = facetSelector
  }
  return facetsSelectors
}

const getOptions = ({ property, worksUrisPerValue, facetsEntitiesBasicInfo }) => {
  return Object.keys(worksUrisPerValue)
  .map(formatOption({ property, worksUrisPerValue, facetsEntitiesBasicInfo }))
}

const hasNoKnownValue = options => {
  return !options.some(option => option.value !== 'all' && option.value !== 'unknown')
}

async function getBasicInfo (uris) {
  uris = uniq(uris)
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'labels', 'image' ],
    lang: app.user.lang
  })
  Object.values(entities).forEach(entity => {
    entity.label = Object.values(entity.labels)[0]
  })
  return entities
}

const facetsProperties = [
  // TODO: include other author properties in that same facet
  'wdt:P50',
  'wdt:P136',
  'wdt:P921',
  'wdt:P577',
]

const valueFormatters = {
  'wdt:P577': getYearFromSimpleDay,
}

export const entityProperties = facetsProperties.filter(property => properties[property].editorType === 'entity')

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
