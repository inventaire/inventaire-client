import wdLang from 'wikidata-lang'
import { getEntitiesAttributesByUris } from '#entities/lib/entities'

export async function fetchLangEntities (uris) {
  const { entities } = await getEntitiesAttributesByUris({
    uris,
    attributes: [ 'labels' ],
    lang: app.user.lang
  })
  return entities
}

export const getWdUri = lang => {
  const langWdId = wdLang.byCode[lang]?.wd
  if (langWdId) return `wd:${langWdId}`
}

export const prioritizeMainUserLang = langs => {
  let userLang = app.user.lang
  if (langs.includes(userLang)) {
    const userLangIndex = langs.indexOf(userLang)
    langs.splice(userLangIndex, 1)
    langs.unshift(userLang)
  }
  return langs
}

