import wdLang from 'wikidata-lang'
import { getEntitiesAttributesByUris } from '#entities/lib/entities'
import { getEntityLang } from '#entities/components/lib/claims_helpers'

async function fetchLangEntities (uris) {
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'labels' ],
    lang: app.user.lang
  })
  return entities
}

const getLangWdUri = lang => {
  const langWdId = wdLang.byCode[lang]?.wd
  if (langWdId) return `wd:${langWdId}`
}

const prioritizeMainUserLang = langs => {
  let userLang = app.user.lang
  if (langs.includes(userLang)) {
    const userLangIndex = langs.indexOf(userLang)
    langs.splice(userLangIndex, 1)
    langs.unshift(userLang)
  }
  return langs
}

export async function getLangEntities (initialEditions) {
  const rawEditionsLangs = _.compact(_.uniq(initialEditions.map(getEntityLang)))
  const editionsLangs = prioritizeMainUserLang(rawEditionsLangs)
  const langsUris = _.compact(editionsLangs.map(getLangWdUri))
  const entities = await fetchLangEntities(langsUris)
  const langEntitiesLabel = {}
  editionsLangs.forEach(lang => {
    const langWdId = getLangWdUri(lang)
    if (langWdId) langEntitiesLabel[lang] = entities[langWdId]
  })
  return { editionsLangs, langEntitiesLabel }
}
