import objectStore from 'lib/components/object_store'

export function getSelectionStore () {
  const selection = objectStore({})

  selection.select = entity => {
    selection.update(data => {
      if (!data.from) {
        if (data.to === entity) data.to = null
        if (entity.prefix === 'wd') data.to = entity
        else data.from = entity
      } else if (!data.to) {
        if (data.from === entity) data.from = null
        data.to = entity
      } else {
        if (entity.prefix === 'wd') {
          data.from = null
          data.to = entity
        } else {
          data.from = entity
          data.to = null
        }
      }
      return data
    })
  }

  selection.reset = () => selection.assign({ from: null, to: null })

  return selection
}

export const getEntityFilter = text => {
  if (!text || text.trim().length === 0) return () => true

  // Using a regex allows to accept OR operators in the form of `|`
  const re = new RegExp(text, 'i')
  return entity => anyLabelOrAliasMatch(entity, re)
}

const anyLabelOrAliasMatch = function (entity, re) {
  entity._matchable = entity._matchable || getEntityLabelsAndAliases(entity)
  return entity._matchable.some(term => term.match(re))
}

const getEntityLabelsAndAliases = entity => {
  const labels = Object.values(entity.labels)
  const aliases = Object.values(entity.aliases || [])
  return labels.concat(...aliases)
}

export const getAggregatedLabelsAndAliases = entity => {
  const terms = {}
  for (const lang in entity.labels) {
    const label = entity.labels[lang]
    terms[label] = terms[label] || []
    terms[label].push(`label.${lang}`)
  }
  for (const lang in entity.aliases) {
    for (const alias of entity.aliases[lang]) {
      terms[alias] = terms[alias] || []
      terms[alias].push(`alias.${lang}`)
    }
  }

  return Object.keys(terms)
  .map(term => ({
    term,
    normalized: term.trim().toLowerCase(),
    getMatchParts: getMatchingParts(term),
    origins: terms[term],
  }))
  .sort((a, b) => {
    if (a.origins.length === b.origins.length) {
      return getTermPreferredOriginsCount(b) - getTermPreferredOriginsCount(a)
    } else {
      return b.origins.length - a.origins.length
    }
  })
}

const getMatchingParts = term => filterPattern => {
  const matching = term.match(filterPattern)[0]
  const parts = term.split(matching).map(partAround => [ partAround, matching ])
  return _.flatten(parts).slice(0, -1)
}

const getTermPreferredOriginsCount = ({ origins }) => origins.filter(isPreferredOrigin).length

const isPreferredOrigin = origin => {
  const lang = origin.split('.')[1]
  return (lang === app.user.lang || lang === 'en')
}
