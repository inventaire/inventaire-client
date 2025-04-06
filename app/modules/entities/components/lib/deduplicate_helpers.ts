import { flatten } from 'underscore'
import { getAuthorWorks } from '#entities/lib/types/author_alt'
import { addWorksImagesAndAuthors } from '#entities/lib/types/work_alt'
import { getCurrentLang } from '#modules/user/lib/i18n'

export const select = (entity, from, to) => {
  if (!from) {
    if (to === entity) to = null
    if (entity.prefix === 'wd') to = entity
    else from = entity
  } else if (!to) {
    if (from === entity) from = null
    to = entity
  } else {
    if (entity.prefix === 'wd') {
      from = null
      to = entity
    } else {
      from = entity
      to = null
    }
  }
  return { from, to }
}

export const getFilterPattern = text => {
  if (!text || text.trim().length === 0) return ''

  // Using a regex allows to accept OR operators in the form of `|`
  let pattern
  try {
    pattern = new RegExp(text, 'i')
  } catch (err) {
    if (err.name !== 'SyntaxError') throw err
    const escapedText = text.replace(/(\W)/g, '\\$1')
    pattern = new RegExp(escapedText, 'i')
  }

  return pattern
}

export const getEntityFilter = (text, pattern) => {
  if (text.length === 0) return () => true
  else return entity => anyLabelOrAliasMatch(entity, pattern)
}

const anyLabelOrAliasMatch = function (entity, pattern) {
  entity._matchable = entity._matchable || getEntityLabelsAndAliases(entity)
  return entity._matchable.some(term => term.match(pattern))
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
  return flatten(parts).slice(0, -1)
}

const getTermPreferredOriginsCount = ({ origins }) => origins.filter(isPreferredOrigin).length

const isPreferredOrigin = origin => {
  const lang = origin.split('.')[1]
  return (lang === getCurrentLang() || lang === 'en')
}

export async function getAuthorWorksWithImagesAndCoauthors (author) {
  const { uri } = author
  const works = await getAuthorWorks({ uri })
  await addWorksImagesAndAuthors(works)
  works.forEach(work => {
    work.coauthors = work.authors.filter(coauthor => coauthor.uri !== author.uri)
  })
  return works
}

export function spreadByPrefix (works) {
  const worksByPrefix = { wd: [], inv: [] }
  works.forEach(work => {
    worksByPrefix[work.prefix].push(work)
  })
  return worksByPrefix
}

export function sortAlphabetically (a, b) {
  const labelA = a.label || ''
  const labelB = b.label || ''
  if (labelA.toLowerCase() > labelB.toLowerCase()) return 1
  else return -1
}
