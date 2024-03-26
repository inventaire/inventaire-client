import { property, compact } from 'underscore'
import app from '#app/app'
import filterOutWdEditions from '../filter_out_wd_editions.ts'
import getEntityItemsByCategories from '../get_entity_items_by_categories.ts'
import commonsSerieWork from './commons_serie_work.ts'

const publicDomainThresholdYear = new Date().getFullYear() - 70

const editionRelationProperty = 'wdt:P629'

export default function () {
  // Main property by which sub-entities are linked to this one: edition of
  this.childrenClaimProperty = editionRelationProperty
  // inverse property: edition(s)
  this.subEntitiesInverseProperty = 'wdt:P747'

  this.usesImagesFromSubEntities = true

  this.subentitiesName = 'editions'
  // extend before fetching sub entities to have access
  // to the custom @beforeSubEntitiesAdd
  Object.assign(this, specificMethods)

  setPublicationYear.call(this)
  setEbooksData.call(this)
}

const setPublicationYear = function () {
  const publicationDate = this.get('claims.wdt:P577.0')
  if (publicationDate != null) {
    this.publicationYear = parseInt(publicationDate.split('-')[0])
    this.inPublicDomain = this.publicationYear < publicDomainThresholdYear
  }
}

const setImage = function () {
  let images
  const editionsImages = compact(this.editions.map(getEditionImageData))
    .sort(bestImage)
    .map(property('image'))

  const workImage = this.get('image')
  // If the work is in public domain, we can expect Wikidata image to be better
  // if there is one. In any other case, prefer images from editions
  // as illustration from Wikidata for copyrighted content can be quite random.
  // Wikipedia and OpenLibrary work images follow the same rule for simplicity
  if ((workImage != null) && this.inPublicDomain) {
    images = [ workImage ].concat(editionsImages)
  } else {
    images = editionsImages
    this.set('image', (images[0] || workImage))
  }

  this.set('images', images.slice(0, 3))
}

const getEditionImageData = function (edition) {
  const image = edition.get('image')
  if (image?.url == null) return
  return {
    image,
    lang: edition.get('lang'),
    publicationDate: edition.get('publicationTime'),
    isCompositeEdition: edition.get('isCompositeEdition'),
  }
}

const bestImage = function (a, b) {
  const { lang: userLang } = app.user
  if (a.isCompositeEdition !== b.isCompositeEdition) {
    if (a.isCompositeEdition) return 1
    else return -1
  } else if (a.lang === b.lang) {
    return latestPublication(a, b)
  } else if (a.lang === userLang) {
    return -1
  } else if (b.lang === userLang) {
    return 1
  } else {
    return latestPublication(a, b)
  }
}

const latestPublication = (a, b) => b.publicationTime - a.publicationTime

const setEbooksData = function () {
  const hasInternetArchivePage = (this.get('claims.wdt:P724.0') != null)
  const hasGutenbergPage = (this.get('claims.wdt:P2034.0') != null)
  const hasWikisourcePage = (this.get('wikisource.url') != null)
  this.set('hasEbooks', (hasInternetArchivePage || hasGutenbergPage || hasWikisourcePage))
  this.set('gutenbergProperty', 'wdt:P2034')
}

const specificMethods = Object.assign({}, commonsSerieWork, {
  // wait for setImage to have run
  async getImageAsync () {
    await this.fetchSubEntities()
    return this.get('image')
  },
  getItemsByCategories: getEntityItemsByCategories,
  beforeSubEntitiesAdd: filterOutWdEditions,
  afterSubEntitiesAdd: setImage,
})
