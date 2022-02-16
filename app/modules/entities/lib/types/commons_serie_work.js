import { props as promiseProps } from '#lib/promises'
export default {
  getExtendedAuthorsModels () {
    return promiseProps({
      'wdt:P50': this.getModelsFromClaims('wdt:P50'),
      'wdt:P58': this.getModelsFromClaims('wdt:P58'),
      'wdt:P110': this.getModelsFromClaims('wdt:P110'),
      'wdt:P6338': this.getModelsFromClaims('wdt:P6338')
    })
  },

  async getModelsFromClaims (property) {
    const uris = this.get(`claims.${property}`)
    if (uris?.length > 0) {
      return app.request('get:entities:models', { uris })
    } else {
      return []
    }
  },

  getExtendedAuthorsUris () {
    return _.chain(authorProperties)
    .map(property => this.get(`claims.${property}`))
    .compact()
    .flatten()
    .uniq()
    .value()
  }
}

const authorProperties = [
  'wdt:P50',
  'wdt:P58',
  'wdt:P110',
  'wdt:P6338'
]
