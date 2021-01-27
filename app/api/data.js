import endpoint from './endpoint'
const { action } = endpoint('data')

export default {
  wikipediaExtract: (lang, title) => action('wp-extract', { lang, title }),
  isbn: isbn => action('isbn', { isbn }),
  propertyValues: (property, type) => action('property-values', { property, type }),
}
