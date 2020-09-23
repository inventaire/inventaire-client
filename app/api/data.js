import endpoint from './endpoint'
const { action } = endpoint('data')

export default {
  wikipediaExtract (lang, title) { return action('wp-extract', { lang, title }) },
  isbn (isbn) { return action('isbn', { isbn }) }
}
