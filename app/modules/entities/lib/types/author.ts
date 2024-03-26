import app from '#app/app'
import preq from '#lib/preq'
import { i18n } from '#user/lib/i18n'

export default function () {
  // Main property by which sub-entities are linked to this one
  this.childrenClaimProperty = 'wdt:P50'

  setEbooksData.call(this)

  return Object.assign(this, specificMethods)
}

const setEbooksData = function () {
  const hasInternetArchivePage = (this.get('claims.wdt:P724.0') != null)
  const hasGutenbergPage = (this.get('claims.wdt:P1938.0') != null)
  const hasWikisourcePage = (this.get('wikisource.url') != null)
  this.set('hasEbooks', (hasInternetArchivePage || hasGutenbergPage || hasWikisourcePage))
  this.set('gutenbergProperty', 'wdt:P1938')
}

const specificMethods = {
  fetchWorksData (refresh) {
    if (!refresh && this.waitForWorksData != null) return this.waitForWorksData
    const uri = this.get('uri')
    this.waitForWorksData = preq.get(app.API.entities.authorWorks(uri, refresh))
    return this.waitForWorksData
  },

  buildTitle () { return i18n('books_by_author', { author: this.get('label') }) },
}
