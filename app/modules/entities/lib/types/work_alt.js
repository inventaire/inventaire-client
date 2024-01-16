import getBestLangValue from '../get_best_lang_value.js'
import { getEntitiesByUris, getEntitiesImages, getEntityImage, getEntityImagePath } from '../entities.js'
import { omit, pluck } from 'underscore'

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
    let { value: imageValue, lang } = getBestLangValue(app.user.lang, entity.originalLang, entityImages)
    if (imageValue) {
      entity.images.push(getEntityImagePath(imageValue))
    }
    const otherLanguagesImages = Object.values(omit(entityImages, [ lang, 'claims' ]))
    const otherLanguagesImagesUrls = otherLanguagesImages.flat().map(getEntityImagePath)
    entity.images.push(...otherLanguagesImagesUrls)
    if (entityImages.claims) entity.images.push(...entityImages.claims.map(getEntityImagePath))
    if (entity.images[0]) {
      entity.image = { url: entity.images[0] }
    }
    console.log('entity.images', entity.images)
  } else if (entity.image?.url) {
    entity.images.push(entity.image.url)
  }
}

export async function addWorksAuthors (works) {
  const authorsUris = _.uniq(_.compact(_.flatten(works.map(getWorkAuthorsUris))))
  const entities = await getEntitiesByUris({ uris: authorsUris, index: true })
  works.forEach(work => {
    const workAuthorUris = getWorkAuthorsUris(work)
    work.authors = _.values(_.pick(entities, workAuthorUris))
  })
}

const getWorkAuthorsUris = work => work.claims['wdt:P50']
