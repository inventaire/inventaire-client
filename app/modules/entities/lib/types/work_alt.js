import getBestLangValue from '../get_best_lang_value.js'
import { getEntitiesByUris, getEntitiesImages, getEntityImage, getEntityImagePath } from '../entities.js'
import { pluck } from 'underscore'

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
  const { type } = entity
  if (type === 'work' || type === 'collection' || type === 'serie') {
    let imageValue = getBestLangValue(app.user.lang, entity.originalLang, entityImages).value
    if (imageValue) {
      entity.image.url = getEntityImagePath(imageValue)
    }
    entity.images = Object.values(entityImages).flat().map(getEntityImagePath)
  } else {
    entity.images = []
    if (entity.image?.url) {
      entity.images.push(entity.image.url)
    }
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
