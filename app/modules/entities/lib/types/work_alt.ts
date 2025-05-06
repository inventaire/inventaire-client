import { pick, uniq, flatten, compact, pluck } from 'underscore'
import { getCurrentLang } from '#modules/user/lib/i18n'
import { getEntitiesByUris, getEntitiesImages, getEntityImage, getEntityImagePath } from '../entities.ts'
import { getBestLangValue } from '../get_best_lang_value.ts'

export async function addWorksImagesAndAuthors (works) {
  await Promise.all([
    addWorksImages(works),
    addWorksAuthors(works),
  ])
  return works
}

export async function addEntitiesImages (works) {
  const remainingEntities = works.slice(0)
  const nextBatch = async () => {
    const batchEntities = remainingEntities.splice(0, 20)
    if (batchEntities.length === 0) return
    await addMissingImages(batchEntities)
    return nextBatch()
  }
  await nextBatch()
  return works
}

export const addWorksImages = addEntitiesImages

async function addMissingImages (entities) {
  const entitiesWithoutImages = entities.filter(entity => !entity.images)
  const uris = pluck(entitiesWithoutImages, 'uri')
  const imagesByUri = await getEntitiesImages(uris)
  entities.forEach(entity => {
    const entityImages = imagesByUri[entity.uri]
    setEntityImages(entity, entityImages)
  })
}

export async function addEntityImages (entity) {
  const { type, uri } = entity
  let entityImages
  if (type === 'work' || type === 'serie') {
    entityImages = await getEntityImage(uri)
  }
  setEntityImages(entity, entityImages)
}

const setEntityImages = (entity, entityImages) => {
  entity.images = []
  if (entityImages) {
    const { lang } = getBestLangValue(getCurrentLang(), entity.originalLang, entityImages)
    const preferredLangImages = entityImages[lang]
    if (preferredLangImages) {
      entity.images = preferredLangImages.map(getEntityImagePath)
    }
    if (entity.images[0]) {
      entity.image = { url: entity.images[0] }
    }
  } else if (entity.image?.url) {
    entity.images = [ entity.image.url ]
  }
}

export async function addWorksAuthors (works) {
  const authorsUris = uniq(compact(flatten(works.map(getWorkAuthorsUris))))
  const entities = await getEntitiesByUris({ uris: authorsUris })
  works.forEach(work => {
    const workAuthorUris = getWorkAuthorsUris(work)
    work.authors = Object.values(pick(entities, workAuthorUris))
  })
}

const getWorkAuthorsUris = work => work.claims['wdt:P50']
